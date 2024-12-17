using azure_app;
using Microsoft.ApplicationInsights.Extensibility;

var builder = WebApplication.CreateBuilder(args);

// Add Application Insights Telemetry
builder.Services.AddApplicationInsightsTelemetry();

// Add services to the container.
builder.Services.AddRazorPages();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Error");
    // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
    app.UseHsts();
}

app.UseHttpsRedirection();
app.UseStaticFiles();
app.UseRouting();

// Middleware to track user connections
app.Use(async (context, next) =>
{
    var connectionId = context.Connection.Id;

    // Add the connection ID when a user connects
    LiveTrafficTracker.AddConnection(connectionId);

    await next();

    // Remove the connection ID after the request is complete
    LiveTrafficTracker.RemoveConnection(connectionId);
});


app.UseAuthorization();

app.MapRazorPages();

app.Run();
