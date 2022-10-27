import 'package:starknet/starknet.dart';

final privateKey = Felt.fromInt(1234);

final accountAddress = Felt.fromHexString(
    "0x32d5c7a7953996056caf92ff4dd83f01ad72a3c418c05f15eb2f472d1e9c9f2");

final erc20Address = Felt.fromHexString(
    "0x4e76f8708774c8162fb4da7abefb3cae94cc51cf3f9b40e0d44f24aabf8a521");

final myWalletAddress = Felt.fromHexString(
    "0x0367c0c4603a29Bc5aCA8E07C6A2776D7C0d325945aBB4f772f448b345Ca4Cf7");

void main() async {
  final provider = JsonRpcProvider(nodeUri: infuraGoerliTestnetUri);

  final signer = Signer(privateKey: privateKey);

  final account = Account(
      provider: provider,
      signer: signer,
      accountAddress: accountAddress,
      chainId: StarknetChainId.testNet);

  final erc20 = ERC20(account: account, address: erc20Address);

  Future<Uint256> account_balance(Felt account) async {
    final balance = await erc20.balanceOf(account);
    print('Balance of ${account.toHexString()}: $balance');
    return balance;
  }

  final name = await erc20.name();
  print('Name: $name');

  final symbol = await erc20.symbol();
  print('Symbol: $symbol');

  final supply = await erc20.totalSupply();
  print('Supply: $supply');

  await account_balance(myWalletAddress);
  await account_balance(accountAddress);

  final allowance = await erc20.allowance(accountAddress, myWalletAddress);
  print('Allowance: $allowance');

  var trx = await erc20.transfer(
    myWalletAddress,
    Uint256(low: Felt.fromInt(1), high: Felt.fromInt(0)),
  );
  print('Transfer Transaction: $trx');
  // wait for transaction ....
  trx = await erc20.approve(
    myWalletAddress,
    Uint256(low: Felt.fromInt(2), high: Felt.fromInt(0)),
  );
  print('Approve transaction: $trx');
}
