use anchor_lang::prelude::*;

use solana_program::alt_bn128::prelude::{alt_bn128_addition, alt_bn128_multiplication, alt_bn128_pairing};

declare_id!("GiM4xoMCQSCZNioTiALPSYHfhNGCEnKX16gKTK51JbXN"); 

#[program]
pub mod curves {
    use super::*;

    pub fn addition(ctx: Context<Bn128>, input: Vec<u8>) -> Result<Vec<u8>>{
        let result = alt_bn128_addition(&input).unwrap();
        Ok(result)
    } 
    pub fn multiplication(ctx: Context<Bn128>, input: Vec<u8>) -> Result<Vec<u8>>{
        let result = alt_bn128_multiplication(&input).unwrap();
        Ok(result)
    } 
    pub fn pairing(ctx: Context<Bn128>, input: Vec<u8>) -> Result<Vec<u8>>{
        let result = alt_bn128_pairing(&input).unwrap();
        Ok(result)
    } 

}

#[derive(Accounts)]
pub struct Bn128 {}

#[error_code]
pub enum Bn128Error {
    #[msg("Bn128 error")]
    MyError
}