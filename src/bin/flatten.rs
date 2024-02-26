use mlua::{self, Table};
use std::io::Read;

fn main() {
    let mut content: String = String::new();
    std::fs::File::open("./src/nxml.lua").unwrap().read_to_string(&mut content).unwrap();
    let lua = mlua::Lua::new();
    let nxml = lua.load(content).eval::<Table>().unwrap();
    lua.globals().set("nxml", nxml).unwrap();
    lua.load("print(nxml.parse('<Entity    name = \\\'aaa\\\'></Entity>'))").exec().unwrap();
    println!("hi_rs!");
}