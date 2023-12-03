import * as anchor from '@coral-xyz/anchor'
import { Program } from '@coral-xyz/anchor'
//@ts-ignore
import { Verifier } from '../target/types/verifier_user'

describe.only('Verifier', () => {
	const provider = anchor.AnchorProvider.env()
	anchor.setProvider(provider)

	const dataAccount = anchor.web3.Keypair.generate()

	const program = anchor.workspace.Verifier as Program<Verifier>

	it('works', async () => {
		const tx = await program.methods
			.new()
			.accounts({ dataAccount: dataAccount.publicKey })
			.signers([dataAccount])
			.rpc()
		console.log('Deploy verifier', tx)

		const tryAddition = await program.methods
			.tryAddition()
			.accounts({
				dataAccount: dataAccount.publicKey,
				curves_programId: 'GiM4xoMCQSCZNioTiALPSYHfhNGCEnKX16gKTK51JbXN',
			})
			.view()
		console.log({ tryAddition })

		const tryMul = await program.methods
			.tryMul()
			.accounts({
				dataAccount: dataAccount.publicKey,
				curves_programId: 'GiM4xoMCQSCZNioTiALPSYHfhNGCEnKX16gKTK51JbXN',
			})
			.view()
		console.log({ tryMul })

		const tryPairing = await program.methods
			.tryPairing()
			.accounts({
				dataAccount: dataAccount.publicKey,
				curves_programId: 'GiM4xoMCQSCZNioTiALPSYHfhNGCEnKX16gKTK51JbXN',
			})
			.view()
		console.log({ tryPairing })

		const proof = [
			[
				'292bc50f76766b6dda7c4b1efb761515c7e56799db65dbcbadf7a0c38cb4e14e',
				'139fab144a9f42e197eda48d50a7eef4509ed37604e2128504a3b0ad6d76b590',
			].map((el) => new anchor.BN(el, 'hex')),
			[
				[
					'1e497bfc3db3fcbc6879bc4a7813f6d915a91a3a58b780e0bc31e2e7fcf1246e',
					'17a2cdb50a3513942a285ae96d329a5b381fb92c9054acacb582097ddf5f886e',
				].map((el) => new anchor.BN(el, 'hex')),
				[
					'21aeafb78df07c3b288edb7570e1ef4a7f57f1e003f58e0c3aa6ccb7a5168980',
					'16278c77c239b595a803c86c127fd7e8202553474f87b7ace8887b3e79fd9ae2',
				].map((el) => new anchor.BN(el, 'hex')),
			],
			[
				'101442be94a14ec429292e80faa945d9332ac10b39c768df30141c129e080909',
				'12b0e1cc424dfb568eb3b88ec8481aba0ac09a5c0c08e6d266954828c0a706d5',
			].map((el) => new anchor.BN(el, 'hex')),
			['0000000000000000000000000000000000000000000000000000000000000021'].map(
				(el) => new anchor.BN(el, 'hex'),
			),
		]

		// console.log({ proof })

		console.log(program.methods)

		const verificationResult = await program.methods
			.verifyProof(...proof)
			.accounts({
				dataAccount: dataAccount.publicKey,
				curves_programId: 'GiM4xoMCQSCZNioTiALPSYHfhNGCEnKX16gKTK51JbXN',
			})
			.view()

		console.log({ verificationResult })
	})
})
