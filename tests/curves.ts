import * as anchor from '@coral-xyz/anchor'
import { Program } from '@coral-xyz/anchor'
import { Curves } from '../target/types/curves' // Adjust with your actual program name

describe.only('Curves', () => {
	// Configure the client to use the local cluster.
	anchor.setProvider(anchor.AnchorProvider.env())

	const program = anchor.workspace.Curves as Program<Curves>

	it('bn128Add', async () => {
		// Example array and indices
		const array = [10, 20, 30, 40, 50].map((el) => new anchor.BN(el))

		// Call the sum_of_elements function
		const sum = await program.methods.bn128Add(array).accounts({}).view()

		console.log('Sum:', sum.toString())
	})
})
