import detail.exceptions as exceptions
import subprocess


def run(command):
    try:
        return subprocess.run(command, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, check=True).stdout
    except FileNotFoundError:
        executable = command[0] if command else '(unknown executable)'
        raise exceptions.OperationFailed(f'Unable to invoke {executable} - check if installed and callable')
    except subprocess.CalledProcessError as e:
        raise exceptions.OperationFailed(e.output.decode())
