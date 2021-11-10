use walp_rs::walp_println;

extern "C" {
    fn forward() -> bool;
    fn backward() -> bool;
    fn upwards() -> bool;
    fn downwards() -> bool;
    fn rotate_right();
    fn rotate_left();
    fn dig_forwards();
    fn dig_up();
    fn dig_down();
    pub fn get_fuel_level() -> u32;
    pub fn refuel();
}

#[derive(Clone, Copy, Debug)]
pub enum Direction {
    North,
    East,
    South,
    West,
}

impl Direction {
    pub fn left(&self) -> Self {
        match *self {
            Self::North => Self::West,
            Self::East => Self::North,
            Self::South => Self::East,
            Self::West => Self::South,
        }
    }
    pub fn right(&self) -> Self {
        match *self {
            Self::North => Self::East,
            Self::East => Self::South,
            Self::South => Self::West,
            Self::West => Self::North,
        }
    }
    pub fn to_vector(&self) -> (i64, i64) {
        match *self {
            Self::North => (0, -1),
            Self::East => (1, 0),
            Self::South => (0, 1),
            Self::West => (-1, 0),
        }
    }
    pub fn from_vector(vec: (i64, i64)) -> Self {
        match vec {
            (0, -1) => Self::North,
            (1, 0) => Self::East,
            (0, 1) => Self::South,
            (-1, 0) => Self::West,
            (_, _) => panic!("unsuppoerted direction ({}, {})", vec.0, vec.1),
        }
    }
    pub fn as_number(&self) -> i32 {
        match *self {
            Self::North => 0,
            Self::East => 1,
            Self::South => 2,
            Self::West => 3,
        }
    }
}

pub struct Mover {
    x: i64,
    y: i64,
    z: i64,
    o: Direction,
}

fn try_move<F: FnMut() -> bool, G: Fn()>(mut f: F, g: G) {
    loop {
        walp_println!("attempt to move");
        let res = f();
        if res {
            break;
        } else {
            let level = unsafe { get_fuel_level() };
            if level != 0 {
                walp_println!("attempt to break block");
                g()
            } else {
                walp_println!("attempt to refuel");
                unsafe { refuel() };
            }
        }
    }
}

impl Mover {
    pub fn new(x: i64, y: i64, z: i64, o: Direction) -> Self {
        Self { x, y, z, o }
    }
    pub fn forward(&mut self) -> bool {
        if unsafe { forward() } {
            let (x, z) = self.o.to_vector();
            self.x += x;
            self.z += z;
            true
        } else {
            false
        }
    }
    pub fn backward(&mut self) -> bool {
        if unsafe { backward() } {
            let (x, z) = self.o.to_vector();
            self.x -= x;
            self.z -= z;
            true
        } else {
            false
        }
    }
    pub fn up(&mut self) -> bool {
        if unsafe { upwards() } {
            self.y += 1;
            true
        } else {
            false
        }
    }
    pub fn down(&mut self) -> bool {
        if unsafe { downwards() } {
            self.y -= 1;
            true
        } else {
            false
        }
    }
    pub fn rotate_right(&mut self) {
        unsafe { rotate_left() };
        self.o = self.o.left();
    }
    pub fn rotate_left(&mut self) {
        unsafe { rotate_right() };
        self.o = self.o.right();
    }
    pub fn get_pos(&self) -> (i64, i64, i64, Direction) {
        (self.x, self.y, self.z, self.o)
    }
    pub fn turn_towards(&mut self, direction: Direction) {
        walp_println!("curr: {:?}, target: {:?}", self.o, direction);
        match (self.o.as_number() - direction.as_number()).rem_euclid(4) {
            0 => {}
            1 => self.rotate_right(),
            2 => {
                self.rotate_right();
                self.rotate_right()
            }
            3 => self.rotate_left(),
            _ => unreachable!(),
        }
    }
    pub fn dig_forward(&self) {
        unsafe { dig_forwards() }
    }
    pub fn dig_up(&self) {
        unsafe { dig_up() }
    }
    pub fn dig_down(&self) {
        unsafe { dig_down() }
    }
    pub fn force_forward(&mut self) {
        try_move(|| self.forward(), || unsafe { dig_forwards() });
    }
    pub fn force_up(&mut self) {
        try_move(|| self.up(), || unsafe { dig_up() });
    }
    pub fn force_down(&mut self) {
        try_move(|| self.down(), || unsafe { dig_down() });
    }
    pub fn delta_x(&mut self, x: i64, force: bool) -> i64 {
        self.turn_towards(Direction::from_vector((x.signum(), 0)));
        for n in 0..x.abs() {
            if force {
                self.force_forward();
            } else if !self.forward() {
                return n;
            }
        }
        x
    }
    pub fn delta_z(&mut self, z: i64, force: bool) -> i64 {
        self.turn_towards(Direction::from_vector((0, z.signum())));
        for n in 0..z.abs() {
            if force {
                self.force_forward();
            } else if !self.forward() {
                return n;
            }
        }
        z
    }
    pub fn delta_y(&mut self, y: i64, force: bool) -> i64 {
        for n in 0..y.abs() {
            // if you find this ugly, it's clippies fault, it told me to merge the nested if statements
            if force {
                if y.signum() == -1 {
                    self.force_down();
                } else {
                    self.force_up();
                }
            } else if y.signum() == -1 {
                if !self.down() {
                    return n;
                }
            } else if !self.up() {
                return n;
            }
        }
        y
    }
}
