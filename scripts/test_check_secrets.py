"""Exercise the publication guard against disposable Git repositories."""
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest


SOURCE = Path(__file__).resolve().parent


class PublicationGuardTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="gymsas-guard-test-")
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.git("init", "--quiet")

    def git(self, *args):
        return subprocess.run(
            ["git", *args], cwd=self.root, check=True,
            stdout=subprocess.PIPE, stderr=subprocess.PIPE,
        )

    def file(self, name, text):
        path = self.root / name
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(text)

    def guard(self, mode):
        result = subprocess.run(
            [sys.executable, str(SOURCE / "check_secrets.py"), mode],
            cwd=self.root, capture_output=True, text=True,
        )
        return result

    def test_safe_templates_and_android_gradle_configuration_pass(self):
        self.file(".env.example", "JWT_SECRET=\n")
        self.file("application.yml", "jwt:\n  secret: ${JWT_SECRET}\n")
        self.file("android/gradle.properties", "android.useAndroidX=true\n")
        self.git("add", ".")
        self.assertEqual(self.guard("--staged").returncode, 0)

    def test_forced_environment_file_is_blocked(self):
        self.file(".gitignore", ".env\n")
        self.file(".env", "LOCAL_VALUE=private\n")
        self.git("add", "--force", ".env")
        self.assertEqual(self.guard("--staged").returncode, 1)

    def test_partially_staged_secret_cannot_be_hidden(self):
        secret = "insecure" + "example123"
        self.file("application.yml", "jwt:\n  secret: " + secret + "\n")
        self.git("add", ".")
        self.file("application.yml", "jwt:\n  secret: ${JWT_SECRET}\n")
        result = self.guard("--staged")
        self.assertEqual(result.returncode, 1)
        self.assertNotIn(secret, result.stdout + result.stderr)
        self.assertEqual(self.guard("--working-tree").returncode, 0)

    def test_untracked_private_key_filename_is_blocked(self):
        self.file("credentials.pem", "synthetic fixture\n")
        self.assertEqual(self.guard("--working-tree").returncode, 1)

    def test_history_remembers_environment_after_deletion(self):
        self.file(".env", "LOCAL_VALUE=private\n")
        self.git("add", ".")
        self.git("-c", "user.name=Security Test", "-c", "user.email=test@example.invalid",
                 "commit", "--quiet", "-m", "fixture")
        self.git("rm", "--quiet", ".env")
        self.git("-c", "user.name=Security Test", "-c", "user.email=test@example.invalid",
                 "commit", "--quiet", "-m", "remove fixture")
        self.assertEqual(self.guard("--staged").returncode, 0)
        self.assertEqual(self.guard("--history").returncode, 1)


if __name__ == "__main__":
    unittest.main()
