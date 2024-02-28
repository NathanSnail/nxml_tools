use mlua::{self, Error, Function, Table};
use std::io::{self,Read};

fn main() -> Result<(), Error> {
    let mut buffer = String::new();

    // Read piped input from stdin
    io::stdin().read_to_string(&mut buffer).expect("Failed to read from stdin");
    let mut content: String = String::new();
    std::fs::File::open("./src/flatten.lua")?.read_to_string(&mut content).unwrap();
    let lua = mlua::Lua::new();
    let parser = lua.load(content).eval::<Function>()?;
    let out: Function = lua.globals().get("print")?;
    out.call::<_, _>(parser.call::<_,Table>((buffer, "/home/nathan/Documents/code/noitadata/data/"))?)?;
   	Ok(())
}