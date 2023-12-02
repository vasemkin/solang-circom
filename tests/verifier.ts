import * as anchor from '@coral-xyz/anchor'
import { Program } from '@coral-xyz/anchor'
//@ts-ignore
import { Verifier } from '../target/types/verifier_user'

describe('Verifier', () => {
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

		const initialVerifierAddress = await program.methods
			.testGetter()
			.accounts({ dataAccount: dataAccount.publicKey })
			.view()
		console.log({ initialVerifierAddress })
	})
})
