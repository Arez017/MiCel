// ==========================================
// DATA.JS — MiCel v3.0
// ==========================================

const tecnicos = [
  { code: 'TEC-00', name: 'Arez Dragneel',   user: 'arez',    rol: 'SuperAdmin',    branch: 'Ambas',          active: true },
  { code: 'TEC-01', name: 'Daniel Choque',    user: 'micel',  rol: 'Administrador', branch: 'Ambas',          active: true },
  { code: 'TEC-02', name: 'Kevin Flores', user: 'kevsolutions', rol: 'Administrador', branch: 'Ambas',          active: true },
  { code: 'TEC-03', name: 'Técnico 03',      user: 'tec03',   rol: 'Técnico',       branch: 'KevSolutions',       active: true },
  { code: 'TEC-04', name: 'Técnico 04',      user: 'tec04',   rol: 'Técnico',       branch: 'KevSolutions',       active: true },
  { code: 'TEC-05', name: 'Técnico 05',      user: 'tec05',   rol: 'Técnico',       branch: 'KevSolutions',       active: true },
  { code: 'TEC-06', name: 'Técnico 06',      user: 'tec06',   rol: 'Técnico',       branch: 'Upea', active: true },
  { code: 'TEC-07', name: 'Técnico 07',      user: 'tec07',   rol: 'Técnico',       branch: 'Upea', active: true },
  { code: 'TEC-08', name: 'Técnico 08',      user: 'tec08',   rol: 'Técnico',       branch: 'Upea', active: true },
  { code: 'TEC-09', name: 'Técnico 09',      user: 'tec09',   rol: 'Técnico',       branch: 'KevSolutions',       active: true },
  { code: 'TEC-10', name: 'Técnico 10',      user: 'tec10',   rol: 'Técnico',       branch: 'Upea', active: false },
];

let ordersData = [
  { code: '#OS-0041', client: 'Juan Quispe',   phone: '72345678', device: 'Samsung A32',    service: 'Cambio de pantalla', techCode: 'TEC-03', branch: 'KevSolutions',       status: 'Listo',       date: '25/04/2026', monto: 280, obs: 'Pantalla original instalada. Garantía 30 días.' },
  { code: '#OS-0040', client: 'María Condori', phone: '71234567', device: 'Xiaomi Redmi 9', service: 'Cambio de batería',  techCode: 'TEC-06', branch: 'Upea', status: 'En proceso',  date: '25/04/2026', monto: 120, obs: 'Batería marca compatible.' },
  { code: '#OS-0039', client: 'Carlos Mamani', phone: '70987654', device: 'iPhone 11',      service: 'Pin de carga',       techCode: 'TEC-04', branch: 'KevSolutions',       status: 'Diagnóstico', date: '24/04/2026', monto: 0,   obs: 'En espera de diagnóstico.' },
  { code: '#OS-0038', client: 'Ana Flores',    phone: '69876543', device: 'Huawei P30',     service: 'Flasheo / Firmware', techCode: 'TEC-07', branch: 'Upea', status: 'Listo',       date: '24/04/2026', monto: 80,  obs: 'Firmware actualizado correctamente.' },
  { code: '#OS-0037', client: 'Pedro Ticona',  phone: '68765432', device: 'Motorola G30',   service: 'Backlight',          techCode: 'TEC-05', branch: 'KevSolutions',       status: 'En proceso',  date: '23/04/2026', monto: 160, obs: 'Requiere lámina backlight 6.5".' },
  { code: '#OS-0036', client: 'Sonia Apaza',   phone: '67654321', device: 'Samsung A12',    service: 'Cambio de pantalla', techCode: 'TEC-08', branch: 'Upea', status: 'Recepción',   date: '23/04/2026', monto: 0,   obs: 'Recién ingresado.' },
];

let stockData = [
  { id: 'REP-001', name: 'Pantalla Samsung A32',         cat: 'Pantallas',        qty: 2,  min: 5,  precio: 180 },
  { id: 'REP-002', name: 'Pantalla Redmi Note 10',       cat: 'Pantallas',        qty: 8,  min: 5,  precio: 160 },
  { id: 'REP-003', name: 'Pantalla Samsung A12',         cat: 'Pantallas',        qty: 6,  min: 5,  precio: 150 },
  { id: 'REP-004', name: 'Pantalla iPhone 11',           cat: 'Pantallas',        qty: 3,  min: 3,  precio: 320 },
  { id: 'REP-005', name: 'Batería Xiaomi Redmi 9',       cat: 'Baterías',         qty: 1,  min: 4,  precio: 60  },
  { id: 'REP-006', name: 'Batería Samsung A12',          cat: 'Baterías',         qty: 6,  min: 4,  precio: 65  },
  { id: 'REP-007', name: 'Batería iPhone 11',            cat: 'Baterías',         qty: 4,  min: 3,  precio: 120 },
  { id: 'REP-008', name: 'Pin de carga USB-C',           cat: 'Conectores',       qty: 15, min: 10, precio: 25  },
  { id: 'REP-009', name: 'Pin de carga Lightning',       cat: 'Conectores',       qty: 3,  min: 5,  precio: 40  },
  { id: 'REP-010', name: 'Lámina Backlight 6.5"',        cat: 'Retroiluminación', qty: 7,  min: 3,  precio: 55  },
  { id: 'REP-011', name: 'Flex cámara Redmi 9',          cat: 'Flex',             qty: 0,  min: 3,  precio: 45  },
  { id: 'REP-012', name: 'Flex cámara Samsung A32',      cat: 'Flex',             qty: 5,  min: 3,  precio: 50  },
  { id: 'REP-013', name: 'Parlante Samsung A32',         cat: 'Audio',            qty: 4,  min: 2,  precio: 35  },
  { id: 'REP-014', name: 'Micrófono Motorola G30',       cat: 'Audio',            qty: 2,  min: 2,  precio: 30  },
  { id: 'REP-015', name: 'Mica templada 6.5" universal', cat: 'Accesorios',       qty: 20, min: 10, precio: 10  },
];

let clientesData = [
  { id: 'CLI-001', name: 'Arez Dragneel',   phone: '72345678', branch: 'KevSolution',       visits: 4, lastVisit: '25/04/2026' },
  { id: 'CLI-002', name: 'María Condori',   phone: '71234567', branch: 'Upea',              visits: 2, lastVisit: '24/04/2026' },
  { id: 'CLI-003', name: 'Carlos Mamani',   phone: '70987654', branch: 'KevSolutions',      visits: 6, lastVisit: '23/04/2026' },
  { id: 'CLI-004', name: 'Ana Flores',      phone: '69876543', branch: 'Upea',              visits: 1, lastVisit: '22/04/2026' },
  { id: 'CLI-005', name: 'Pedro Ticona',    phone: '68765432', branch: 'KevSolutions',      visits: 3, lastVisit: '21/04/2026' },
  { id: 'CLI-006', name: 'Sonia Apaza',     phone: '67654321', branch: 'Upea',              visits: 1, lastVisit: '20/04/2026' },
];

let recibosData   = [];
let orderCounter  = 42;
let reciboCounter = 1;
let repCounter    = 16;
let cliCounter    = 7;
