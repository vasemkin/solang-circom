use anchor_lang::prelude::*;

declare_id!("GiM4xoMCQSCZNioTiALPSYHfhNGCEnKX16gKTK51JbXN"); // Replace with your program's deployed address

#[program]
pub mod curves {
    use super::*;

    pub fn bn128_add(_ctx: Context<SumOfElements>, array: Vec<u64>) -> Result<u64> {
        let element1 = array[0];
        let element2 = array[1];
        let sum = element1 + element2;
        msg!("The sum is: {}", sum);
        Ok(sum)
    }
}

#[derive(Accounts)]
pub struct SumOfElements {}


#[derive(Accounts)]
pub struct BnAdd {}