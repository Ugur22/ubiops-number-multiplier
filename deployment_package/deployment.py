import os


class Deployment:
    def __init__(self, base_directory, context):
        # Env var lets the factor change without editing the code (not wired up in Terraform yet).
        self.factor = float(os.environ.get("MULTIPLIER_FACTOR", "2"))

    def request(self, data, context):
        return {"output": data["input"] * self.factor}
