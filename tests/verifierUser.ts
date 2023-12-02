import * as anchor from '@coral-xyz/anchor'
import { Program } from '@coral-xyz/anchor'
//@ts-ignore
import { VerifierUser } from '../target/types/verifier_user'
import { Verifier } from '../target/types/Verifier'

describe.only('VerifierUser', () => {
	const provider = anchor.AnchorProvider.env()
	anchor.setProvider(provider)

	const userDataAccount = anchor.web3.Keypair.generate()

	const verifierDataAccount = anchor.web3.Keypair.generate()

	const verifierUserProgram = anchor.workspace.VerifierUser as Program<VerifierUser>
	const verifierProgram = anchor.workspace.Verifier as Program<Verifier>

	it('works', async () => {
		const vuDeployTx = await verifierUserProgram.methods
			.new()
			.accounts({ dataAccount: userDataAccount.publicKey })
			.signers([userDataAccount])
			.rpc()
		console.log('verifier user deploy tx', vuDeployTx)

		const vDeployTx = await verifierProgram.methods
			.new()
			.accounts({ dataAccount: verifierDataAccount.publicKey })
			.signers([verifierDataAccount])
			.rpc()
		console.log('verifier deploy tx', vDeployTx)

		await verifierUserProgram.methods
			.setVerifier(verifierProgram.programId)
			.accounts({ dataAccount: userDataAccount.publicKey })
			.rpc()

		const verifyResult = await verifierUserProgram.methods
			.verify()
			.accounts({
				Verifier_programId: verifierProgram.programId,
			})
			.view()

		console.log({ verifyResult })

		const callRustResult = await verifierUserProgram.methods
			.callRust()
			.accounts({ simpler_storage_programId: '42av5xMETnHvp2o7maUGqpLZNGzFqiLj1W3YAPN75J9i' })
			.view()
		console.log({ callRustResult })
	})
})
