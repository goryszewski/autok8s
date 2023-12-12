import libvirt_inventory
import pytest
import libvirt

class mock_libvirt:
    def listAllDomains(self,type):
        return {}

@pytest.fixture
def mock_host(monkeypatch):
    def mock_get(url):
        return mock_libvirt()
    monkeypatch.setattr(libvirt, "open", mock_get)

@pytest.fixture
def host():
    return libvirt_inventory.Host()
def test_invent():

    assert True

# DOTO

# test connect to host
# test Domain
# test List domain

def test_connect_to_host(mock_host,host):
    assert host
    assert {} == host.get_vm()
