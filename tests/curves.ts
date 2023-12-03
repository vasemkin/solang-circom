import * as anchor from '@coral-xyz/anchor'
import { Program } from '@coral-xyz/anchor'
import { Curves } from '../target/types/curves' // Adjust with your actual program name

describe('Curves', () => {
	// Configure the client to use the local cluster.
	anchor.setProvider(anchor.AnchorProvider.env())

	const program = anchor.workspace.Curves as Program<Curves>

	function hexToBytes(hex) {
		let bytes = []
		for (let c = 0; c < hex.length; c += 2) bytes.push(parseInt(hex.substr(c, 2), 16))
		return bytes
	}

	const input =
		'18b18acfb4c2c30276db5411368e7185b311dd124691610c5d3b74034e093dc9063c909c4720840cb5134cb9f59fa749755796819658d32efc0d288198f3726607c2b7f58a84bd6145f00c9c2bc0bb1a187f20ff2c92963a88019e7c6a014eed06614e20c147e940f2d70da3f74c9a17df361706a4485c742bd6788478fa17d7'

	it('bn128Add', async () => {
		const array = hexToBytes(input)

		const sum = await program.methods.addition(Buffer.from(array)).accounts({}).view()

		console.log({ sum })
	})
})
