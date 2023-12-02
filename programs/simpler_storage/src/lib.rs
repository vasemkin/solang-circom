use anchor_lang::prelude::*;

declare_id!("42av5xMETnHvp2o7maUGqpLZNGzFqiLj1W3YAPN75J9i");

#[program]
pub mod simpler_storage {
    use super::*;

    pub fn view_function(ctx: Context<ViewFunction>) -> Result<u64> {
        let value: u64 = 2298;
        Ok(value)
    }
}

#[derive(Accounts)]
pub struct ViewFunction {}

