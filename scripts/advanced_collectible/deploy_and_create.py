from scripts.helpful_scripts import (
    get_account,
    get_contract,
    fund_with_link,
)
from brownie import AdvancedCollectible, network, config


def deploy_and_create():
    account = get_account()
    # We want to be able to use the deployed contracts if we are on a testnet
    # otherwise we use Rinkeby to deploy Mocks
    advanced_collectible = AdvancedCollectible.deploy(
        get_contract("vrf_coordinator"),
        get_contract("link_token"),
        config["networks"][network.show_active()]["keyhash"],
        config["networks"][network.show_active()]["fee"],
        {"from": account},
    )
    fund_with_link(advanced_collectible.address)
    creating_tx = advanced_collectible.createCollectible({"from": account})
    creating_tx.wait(1)
    print("New token has been created! Yeah!!!")
    return advanced_collectible, creating_tx


def main():
    deploy_and_create()
