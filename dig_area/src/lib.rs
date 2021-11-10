use walp_rs::walp_println;

mod movement;
use movement::Direction;

#[no_mangle]
extern "C" fn main(mut x: i32, mut y: i32, mut z: i32) {
    let mut pos = movement::Mover::new(0, 0, 0, Direction::East);
    walp_println!("i wanna dig a ({}, {}, {}) area!", x, y, z);
    x -= x.signum();
    y -= y.signum();
    z -= z.signum();
    for y_d in 0..y.abs() + 1 {
        for z_d in 0..z.abs() + 1 {
            pos.delta_x(x as _, true);
            pos.delta_x(-x as _, true);
            if z_d != z.abs() {
                pos.delta_z(z.signum() as _, true);
            }
        }
        pos.delta_z(-z as _, true);
        if y_d != y.abs() {
            pos.delta_y(y.signum() as _, true);
        }
    }
    pos.delta_y(-y as _, true);
    pos.turn_towards(Direction::East);
}
