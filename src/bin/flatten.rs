use mlua;
use std::io::Read;

fn main() {
    let mut content: String = String::new();
    std::fs::File::open("./nxml.lua").unwrap().read_to_string(&mut content).unwrap();
    let lua = mlua::Lua::new();
    let _ = lua.load("print('hi')").exec();
    println!("hi_rs!");
}