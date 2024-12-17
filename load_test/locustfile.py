from locust import HttpUser, task

class TrafficSimulation(HttpUser):
    @task
    def simulate_traffic(self):
        self.client.get("/")
