import importlib.util
from pathlib import Path

import pytest

path = Path(__file__).resolve().parents[1] / 'scripts/launch.py'
spec = importlib.util.spec_from_file_location('fsm_launch', path)
launch = importlib.util.module_from_spec(spec)
spec.loader.exec_module(launch)


def test_default_port_is_used_when_free():
    assert launch.choose_port(lambda port: True, lambda port: False) == 8000


def test_port_held_by_another_program_is_skipped():
    assert launch.choose_port(lambda port: port != 8000, lambda port: False) == 8001


def test_running_copy_of_the_app_is_reused():
    assert launch.choose_port(lambda port: port not in {8000, 8003}, lambda port: port == 8003) == 8003


def test_reports_when_every_port_is_taken():
    with pytest.raises(SystemExit):
        launch.choose_port(lambda port: False, lambda port: False, span=3)
