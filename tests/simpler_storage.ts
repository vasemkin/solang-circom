import * as anchor from '@coral-xyz/anchor'
import { Program } from '@coral-xyz/anchor'
import { SimplerStorage } from '../target/types/simpler_storage'

describe('simpler_storage', () => {
	// Configure the client to use the local cluster.
	anchor.setProvider(anchor.AnchorProvider.env())

	const program = anchor.workspace.SimplerStorage as Program<SimplerStorage>

	it('The getters work!', async () => {
		// Add your test here.
		const rustView = await program.methods.viewFunction().view()
		console.log({ rustView })
	})
})
