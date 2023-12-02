import * as anchor from '@coral-xyz/anchor'
import { Program } from '@coral-xyz/anchor'
//@ts-ignore
import { VerifierUser } from '../target/types/simple_storage'

describe('VerifierUser', () => {
	const provider = anchor.AnchorProvider.env()
	anchor.setProvider(provider)

	const dataAccount = anchor.web3.Keypair.generate()

	const program = anchor.workspace.VerifierUser as Program<VerifierUser>

	it('works', async () => {
		const tx = await program.methods
			.new()
			.accounts({ dataAccount: dataAccount.publicKey })
			.signers([dataAccount])
			.rpc()
		console.log('Deploy tx', tx)

		const initialVerifierAddress = await program.methods
			.getVerifier()
			.accounts({ dataAccount: dataAccount.publicKey })
			.view()
		console.log({ initialVerifierAddress })
	})
})
