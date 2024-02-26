use mlua;

fn main() {
    let lua = mlua::Lua::new();
    let _ = lua.load("print('hi')").exec();
    println!("hi_rs!");
}