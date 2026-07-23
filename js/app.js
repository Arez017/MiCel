// ==========================================
// APP.JS — MiCel v3.0 (MVP standalone, sin backend)
// ==========================================

// ===== USUARIOS DEL SISTEMA =====
const usuarios = [
  { user: 'arez',    pass: '017',  techCode: 'TEC-00', name: 'Arez Dragneel',   rol: 'Super Admin' },
  { user: 'micel',  pass: '1234', techCode: 'TEC-01', name: 'Daniel Choque',    rol: 'Administrador' },
  { user: 'kevsolutions', pass: '1234', techCode: 'TEC-02', name: 'Kevin Flores', rol: 'Administrador' },
  { user: 'tec03',   pass: '1234', techCode: 'TEC-03', name: 'Técnico 03',      rol: 'Técnico' },
  { user: 'tec04',   pass: '1234', techCode: 'TEC-04', name: 'Técnico 04',      rol: 'Técnico' },
  { user: 'tec05',   pass: '1234', techCode: 'TEC-05', name: 'Técnico 05',      rol: 'Técnico' },
  { user: 'tec06',   pass: '1234', techCode: 'TEC-06', name: 'Técnico 06',      rol: 'Técnico' },
  { user: 'tec07',   pass: '1234', techCode: 'TEC-07', name: 'Técnico 07',      rol: 'Técnico' },
  { user: 'tec08',   pass: '1234', techCode: 'TEC-08', name: 'Técnico 08',      rol: 'Técnico' },
  { user: 'tec09',   pass: '1234', techCode: 'TEC-09', name: 'Técnico 09',      rol: 'Técnico' },
  { user: 'tec10',   pass: '1234', techCode: 'TEC-10', name: 'Técnico 10',      rol: 'Técnico' },
];

let currentUser = null;

// ===== LOGIN (local, sin backend) =====
function doLogin() {
  const user = document.getElementById('login-user').value.trim();
  const pass = document.getElementById('login-pass').value.trim();

  const found = usuarios.find(u => u.user === user && u.pass === pass);
  if (!found) {
    document.getElementById('login-error').style.display = 'block';
    return;
  }

  document.getElementById('login-error').style.display = 'none';
  currentUser = found;
  document.getElementById('login-screen').classList.add('hidden');
  document.getElementById('app').classList.remove('hidden');
  applyUserSession();
  initApp();
}

function applyUserSession() {
  const ini = initials(currentUser.name);
  document.getElementById('sidebar-avatar').textContent  = ini;
  document.getElementById('sidebar-name').textContent    = currentUser.name;
  document.getElementById('sidebar-role').textContent    = currentUser.rol;
  const rolBadgeEl = document.getElementById('topbar-rol');
  if (rolBadgeEl) {
    rolBadgeEl.textContent  = currentUser.rol;
    rolBadgeEl.className    = 'badge ' + (currentUser.rol === 'Administrador' ? 'badge-purple' : 'badge-amber');
  }
  const navUsuarios = document.getElementById('nav-usuarios');
  if (navUsuarios) navUsuarios.style.display = currentUser.rol === 'Técnico' ? 'none' : '';
}

function doLogout() {
  currentUser = null;
  document.getElementById('app').classList.add('hidden');
  document.getElementById('login-screen').classList.remove('hidden');
  document.getElementById('login-user').value = '';
  document.getElementById('login-pass').value = '';
}
document.addEventListener('keydown', e => {
  if (e.key === 'Enter' && !document.getElementById('login-screen').classList.contains('hidden')) doLogin();
});

// ===== INIT =====
function initApp() {
  populateTechSelects();
  renderDashOrders();
  renderOrders(ordersData);
  renderStock(stockData);
  renderVentas();
  renderInventarioCelulares(celularesInventario);
  renderCelulares(celularesData);
  renderUsers();
  renderReportTech();
  renderClientes(clientesData);
  renderRecibosHistorial();
  populateReciboOrden();
}

// ===== NAV =====
const navConfig = {
  dashboard: { title: 'Principal',             sub: 'Resumen general del sistema',              btn: '+ Nueva Orden'    },
  ordenes:   { title: 'Órdenes de Servicio',   sub: 'Registro y seguimiento de reparaciones',   btn: '+ Nueva Orden'    },
  stock:     { title: 'Control de Stock',      sub: 'Inventario de repuestos tecnológicos',     btn: '+ Agregar repuesto'},
  ventas:    { title: 'Ventas',                sub: 'Registro de ingresos por servicio y venta',btn: '+ Registrar venta' },
  celulares: { title: 'Venta de Celulares',    sub: 'Compra y venta de equipos nuevos y usados', btn: '+ Registrar venta' },
  reportes:  { title: 'Reportes',              sub: 'Análisis operativo y financiero',          btn: 'Exportar PDF'     },
  clientes:  { title: 'Clientes',              sub: 'Base de datos de clientes atendidos',      btn: '+ Nuevo cliente'  },
  usuarios:  { title: 'Usuarios / Técnicos',   sub: 'Gestión de accesos y roles del sistema',   btn: '+ Nuevo usuario'  },
  recibos:   { title: 'Recibos',               sub: 'Generación e impresión de recibos',        btn: '+ Nuevo recibo'   },
};

function nav(id, el) {
  document.querySelectorAll('.panel').forEach(p => p.classList.remove('active'));
  document.querySelectorAll('.nav-item').forEach(n => n.classList.remove('active'));
  document.getElementById('panel-' + id).classList.add('active');
  if (el) el.classList.add('active');
  const cfg = navConfig[id] || {};
  document.getElementById('topbar-title').textContent = cfg.title || id;
  document.getElementById('topbar-sub').textContent   = cfg.sub   || '';
  document.getElementById('topbar-btn').textContent   = cfg.btn   || '';
  document.getElementById('topbar-btn').onclick = () => topAction(id);
  closeSidebarMobile(); // en móvil, cierra el menú al elegir una sección
}

function topAction(id) {
  if (id === 'dashboard' || id === 'ordenes') openModal('orden');
  else if (id === 'stock')   openModal('repuesto');
  else if (id === 'ventas')  openModal('venta');
  else if (id === 'celulares') document.getElementById('cel-modelo')?.focus();
  else if (id === 'clientes')openModal('cliente');
  else if (id === 'recibos') openModal('recibo-manual');
  else alert(navConfig[id]?.btn || 'Acción');
}

// ===== SIDEBAR RESPONSIVE (drawer en móvil) =====
function toggleSidebar() {
  document.querySelector('.sidebar').classList.toggle('open');
  document.getElementById('sidebar-backdrop').classList.toggle('open');
}
function closeSidebarMobile() {
  document.querySelector('.sidebar').classList.remove('open');
  document.getElementById('sidebar-backdrop').classList.remove('open');
}

// ===== HELPERS =====
function getTech(code)   { return tecnicos.find(t => t.code === code) || { name: '—', code: '—' }; }
function initials(name)  { return name.split(' ').map(w => w[0]).join('').slice(0,2).toUpperCase(); }
function fmtMonto(v)     { return parseFloat(v||0).toLocaleString('es-BO', {minimumFractionDigits:0}); }
function nowTime()       { return new Date().toLocaleTimeString('es-BO', {hour:'2-digit',minute:'2-digit'}); }
function nowDate()       { return new Date().toLocaleDateString('es-BO'); }

function statusBadge(s) {
  const m = {'Listo':'badge-green','En proceso':'badge-blue','Diagnóstico':'badge-amber','Recepción':'badge-red'};
  return `<span class="badge ${m[s]||'badge-blue'}">${s}</span>`;
}
function stockBadge(qty, min) {
  if (qty===0)    return `<span class="badge badge-red">Sin stock</span>`;
  if (qty < min)  return `<span class="badge badge-amber">Crítico</span>`;
  return `<span class="badge badge-green">OK</span>`;
}
function stockColor(qty, min) {
  if (qty===0)  return '#e02424';
  if (qty<min)  return '#c27803';
  return '#0e9f6e';
}

function populateTechSelects() {
  const opts = tecnicos.filter(t=>t.active).map(t=>`<option value="${t.code}">${t.code} — ${t.name}</option>`).join('');
  ['modal-tech','recibo-tech','venta-tech'].forEach(id => { const el=document.getElementById(id); if(el) el.innerHTML=opts; });
}

// ===== DASHBOARD =====
function renderDashOrders() {
  document.getElementById('dash-orders').innerHTML = ordersData.slice(0,6).map(o=>`
    <tr>
      <td><code class="code-tag">${o.code}</code></td>
      <td>${o.client}</td>
      <td>${o.device} — ${o.service}</td>
      <td>${getTech(o.techCode).name}</td>
      <td>${o.branch}</td>
      <td>${statusBadge(o.status)}</td>
    </tr>`).join('');
}

// ===== ÓRDENES =====
function renderOrders(data) {
  document.getElementById('orders-body').innerHTML = data.map(o=>`
    <tr>
      <td><code class="code-tag">${o.code}</code></td>
      <td>${o.client}</td>
      <td>${o.device}</td>
      <td>${o.service}</td>
      <td><div class="avatar-cell"><div class="avatar">${initials(getTech(o.techCode).name)}</div>${getTech(o.techCode).name}</div></td>
      <td>${o.branch}</td>
      <td>${statusBadge(o.status)}</td>
      <td style="font-weight:600">${o.monto>0?'Bs '+fmtMonto(o.monto):'<span style="color:var(--gray-400)">—</span>'}</td>
      <td>
        <div style="display:flex;gap:4px;flex-wrap:wrap">
          <button class="btn-sm" onclick="cambiarEstado('${o.code}')">Estado</button>
          <button class="btn-sm" onclick="editarOrden('${o.code}')">Editar</button>
          <button class="btn-sm btn-sm-primary" onclick="verReciboOrden('${o.code}')">Recibo</button>
        </div>
      </td>
    </tr>`).join('');
}

function filterOrders(q) {
  renderOrders(ordersData.filter(o=>
    o.code.toLowerCase().includes(q.toLowerCase()) ||
    o.client.toLowerCase().includes(q.toLowerCase()) ||
    o.device.toLowerCase().includes(q.toLowerCase())
  ));
}

function filterSucursal(v) {
  renderOrders(v==='all' ? ordersData : ordersData.filter(o=>o.branch.includes(v)));
}

// Ver recibo automático desde orden
function verReciboOrden(code) {
  const o = ordersData.find(x=>x.code===code);
  if (!o) return;
  const existente = recibosData.find(r=>r.orden===o.code);
  if (existente) {
    mostrarVistaPrevia(existente);
    return;
  }
  if (o.monto <= 0) {
    alert('Esta orden aún no tiene monto asignado.\nVe a "Editar" para ingresar el precio del servicio.');
    return;
  }
  const numRecibo = `REC-${String(reciboCounter).padStart(4,'0')}`;
  const recibo = {
    numRecibo,
    ordenCode: o.code,
    orden: o.code,
    cliente: o.client,
    telefono: o.phone || '—',
    equipo: o.device,
    servicio: o.service,
    monto: o.monto,
    pago: 'Efectivo',
    techCode: (currentUser && currentUser.rol === 'Técnico') ? currentUser.techCode : o.techCode,
    sucursal: o.branch,
    obs: o.obs || 'Garantía de 30 días por el servicio realizado.',
    tipo: 'Recibo de servicio técnico',
    hora: nowTime(),
    fecha: nowDate(),
  };
  recibosData.push(recibo);
  reciboCounter++;
  renderRecibosHistorial();
  populateReciboOrden();
  mostrarVistaPrevia(recibo);
}

// Editar orden — abre modal precargado
function editarOrden(code) {
  const o = ordersData.find(x=>x.code===code);
  if (!o) return;
  document.getElementById('edit-order-code').value    = o.code;
  document.getElementById('edit-order-client').value  = o.client;
  document.getElementById('edit-order-phone').value   = o.phone||'';
  document.getElementById('edit-order-device').value  = o.device;
  document.getElementById('edit-order-service').value = o.service;
  document.getElementById('edit-order-monto').value   = o.monto||0;
  document.getElementById('edit-order-obs').value     = o.obs||'';
  const ss = document.getElementById('edit-order-status');
  for(let i=0;i<ss.options.length;i++) if(ss.options[i].value===o.status){ss.selectedIndex=i;break;}
  const ts = document.getElementById('edit-order-tech');
  for(let i=0;i<ts.options.length;i++) if(ts.options[i].value===o.techCode){ts.selectedIndex=i;break;}
  openModal('editar-orden');
}

function guardarEdicionOrden() {
  const code = document.getElementById('edit-order-code').value;
  const idx  = ordersData.findIndex(x=>x.code===code);
  if (idx<0) return;
  ordersData[idx].client  = document.getElementById('edit-order-client').value.trim();
  ordersData[idx].phone   = document.getElementById('edit-order-phone').value.trim();
  ordersData[idx].device  = document.getElementById('edit-order-device').value.trim();
  ordersData[idx].service = document.getElementById('edit-order-service').value.trim();
  ordersData[idx].monto   = parseFloat(document.getElementById('edit-order-monto').value)||0;
  ordersData[idx].obs     = document.getElementById('edit-order-obs').value.trim();
  ordersData[idx].status  = document.getElementById('edit-order-status').value;
  ordersData[idx].techCode= document.getElementById('edit-order-tech').value;
  closeModal();
  renderOrders(ordersData);
  renderDashOrders();
  populateReciboOrden();
}

// Nueva orden manual
function guardarOrden() {
  const client  = document.getElementById('modal-client').value.trim();
  const phone   = document.getElementById('modal-phone').value.trim();
  const device  = document.getElementById('modal-device').value.trim();
  const service = document.getElementById('modal-service').value;
  const monto   = parseFloat(document.getElementById('modal-monto').value)||0;
  const obs     = document.getElementById('modal-obs').value.trim();
  const branch  = document.getElementById('modal-branch').value;
  const techCode= document.getElementById('modal-tech').value;
  if (!client||!device||!service) { alert('Complete: Cliente, Equipo y Servicio.'); return; }
  const code = `#OS-00${orderCounter++}`;
  const assignedTech = currentUser && currentUser.rol === 'Técnico' ? currentUser.techCode : techCode;
  ordersData.unshift({ code, client, phone, device, service, techCode: assignedTech, branch, status:'Recepción', date:nowDate(), monto, obs });
  if (!clientesData.find(c=>c.phone===phone&&c.name===client)) {
    clientesData.push({ id:`CLI-${String(cliCounter).padStart(3,'0')}`, name:client, phone, branch, visits:1, lastVisit:nowDate() });
    cliCounter++;
    renderClientes(clientesData);
  }
  closeModal();
  renderOrders(ordersData);
  renderDashOrders();
  populateReciboOrden();
  nav('ordenes', document.querySelectorAll('.nav-item')[1]);
}

// ===== STOCK =====
function renderStock(data) {
  document.getElementById('stock-body').innerHTML = data.map(s=>{
    const pct   = Math.min(100, Math.round((s.qty/Math.max(s.min*2,1))*100));
    const color = stockColor(s.qty, s.min);
    return `
      <tr>
        <td><code class="code-tag" style="font-size:10px">${s.id}</code></td>
        <td>${s.name}</td>
        <td>${s.cat}</td>
        <td style="font-weight:600;color:${s.qty<s.min?'var(--danger)':'var(--gray-800)'}">${s.qty}</td>
        <td>${s.min}</td>
        <td>Bs ${fmtMonto(s.precio)}</td>
        <td>
          <div class="stock-bar-wrap">
            <div class="stock-bg"><div class="stock-fill-inner" style="width:${pct}%;background:${color}"></div></div>
            <span style="font-size:11px;color:var(--gray-400)">${pct}%</span>
          </div>
        </td>
        <td>${stockBadge(s.qty, s.min)}</td>
        <td>
          <div style="display:flex;gap:4px">
            <button class="btn-sm" onclick="editarRepuesto('${s.id}')">Editar</button>
            <button class="btn-sm btn-sm-primary" onclick="ajustarStock('${s.id}')">${s.qty===0?'Reabastecer':'Stock'}</button>
          </div>
        </td>
      </tr>`;
  }).join('');
}

function filterStock(q) {
  renderStock(stockData.filter(s=>
    s.name.toLowerCase().includes(q.toLowerCase()) ||
    s.cat.toLowerCase().includes(q.toLowerCase()) ||
    s.id.toLowerCase().includes(q.toLowerCase())
  ));
}

function ajustarStock(id) {
  const s = stockData.find(x=>x.id===id);
  if (!s) return;
  document.getElementById('adj-id').value    = id;
  document.getElementById('adj-name').value  = s.name;
  document.getElementById('adj-qty').value   = s.qty;
  document.getElementById('adj-min').value   = s.min;
  document.getElementById('adj-precio').value= s.precio;
  openModal('ajuste-stock');
}

function guardarAjusteStock() {
  const id  = document.getElementById('adj-id').value;
  const idx = stockData.findIndex(x=>x.id===id);
  if (idx<0) return;
  const s   = stockData[idx];

  const op  = document.getElementById('adj-operacion').value;
  const val = parseInt(document.getElementById('adj-cantidad').value);
  const minVal    = parseInt(document.getElementById('adj-min').value);
  const precioVal = parseFloat(document.getElementById('adj-precio').value);

  // ===== Validaciones de cantidad =====
  if (isNaN(val) || val < 0) {
    alert('La cantidad debe ser un número positivo.');
    return;
  }

  let nuevaQty = s.qty;

  if (op === 'sub') {
    if (s.qty === 0) {
      alert(`"${s.name}" ya está SIN STOCK (0 unidades). Debes reabastecer antes de restar.`);
      return;
    }
    if (val > s.qty) {
      alert(`No puedes restar ${val} unidades: solo hay ${s.qty} disponibles de "${s.name}".`);
      return;
    }
    nuevaQty = s.qty - val;
  } else if (op === 'add') {
    nuevaQty = s.qty + val;
  } else if (op === 'set') {
    nuevaQty = val;
  }

  // Confirmación antes de dejar el producto en 0
  if (nuevaQty === 0 && s.qty !== 0) {
    const continuar = confirm(`Este ajuste dejará "${s.name}" SIN STOCK (0 unidades).\n¿Deseas continuar?`);
    if (!continuar) return;
  }

  // ===== Validaciones de mínimo y precio =====
  if (isNaN(minVal) || minVal < 1) {
    alert('El stock mínimo debe ser al menos 1 unidad.');
    return;
  }
  if (isNaN(precioVal) || precioVal < 0) {
    alert('El precio no puede ser negativo.');
    return;
  }

  stockData[idx].qty    = nuevaQty;
  stockData[idx].min    = minVal;
  stockData[idx].precio = precioVal;
  closeModal();
  renderStock(stockData);

  // Aviso adicional si quedó en estado crítico (pero no en 0)
  if (nuevaQty > 0 && nuevaQty < minVal) {
    alert(`⚠️ "${s.name}" quedó en nivel CRÍTICO (${nuevaQty} de ${minVal} unidades mínimas). Considera reabastecer pronto.`);
  }
}

function editarRepuesto(id) {
  const s = stockData.find(x=>x.id===id);
  if (!s) return;
  document.getElementById('edit-rep-id').value     = id;
  document.getElementById('edit-rep-name').value   = s.name;
  document.getElementById('edit-rep-cat').value    = s.cat;
  document.getElementById('edit-rep-qty').value    = s.qty;
  document.getElementById('edit-rep-min').value    = s.min;
  document.getElementById('edit-rep-precio').value = s.precio;
  openModal('editar-repuesto');
}

function guardarEdicionRepuesto() {
  const id  = document.getElementById('edit-rep-id').value;
  const idx = stockData.findIndex(x=>x.id===id);
  if (idx<0) return;

  const qty    = parseInt(document.getElementById('edit-rep-qty').value);
  const min    = parseInt(document.getElementById('edit-rep-min').value);
  const precio = parseFloat(document.getElementById('edit-rep-precio').value);

  if (isNaN(qty) || qty < 0) { alert('La cantidad no puede ser negativa.'); return; }
  if (isNaN(min) || min < 1) { alert('El stock mínimo debe ser al menos 1 unidad.'); return; }
  if (isNaN(precio) || precio < 0) { alert('El precio no puede ser negativo.'); return; }

  const nuevoNombre = document.getElementById('edit-rep-name').value.trim();
  const nuevaCat    = document.getElementById('edit-rep-cat').value.trim();
  const yaExiste = stockData.some(s =>
    s.id !== id &&
    s.name.trim().toLowerCase() === nuevoNombre.toLowerCase() &&
    s.cat.trim().toLowerCase()  === nuevaCat.toLowerCase()
  );
  if (yaExiste) {
    alert(`Ya existe otro repuesto llamado "${nuevoNombre}" en la categoría "${nuevaCat}". Usa un nombre distinto o edita ese repuesto directamente.`);
    return;
  }

  if (qty === 0 && stockData[idx].qty !== 0) {
    const continuar = confirm(`Este cambio dejará "${stockData[idx].name}" SIN STOCK (0 unidades).\n¿Deseas continuar?`);
    if (!continuar) return;
  }

  stockData[idx].name   = nuevoNombre;
  stockData[idx].cat    = nuevaCat;
  stockData[idx].qty    = qty;
  stockData[idx].min    = min;
  stockData[idx].precio = precio;
  closeModal();
  renderStock(stockData);
}

function guardarRepuesto() {
  const name   = document.getElementById('new-rep-name').value.trim();
  const cat    = document.getElementById('new-rep-cat').value.trim();
  const qty    = parseInt(document.getElementById('new-rep-qty').value);
  const min    = parseInt(document.getElementById('new-rep-min').value);
  const precio = parseFloat(document.getElementById('new-rep-precio').value);

  if (!name||!cat) { alert('Complete nombre y categoría.'); return; }
  if (isNaN(qty) || qty < 0) { alert('La cantidad no puede ser negativa.'); return; }
  if (isNaN(min) || min < 1) { alert('El stock mínimo debe ser al menos 1 unidad.'); return; }
  if (isNaN(precio) || precio < 0) { alert('El precio no puede ser negativo.'); return; }

  const yaExiste = stockData.some(s =>
    s.name.trim().toLowerCase() === name.toLowerCase() &&
    s.cat.trim().toLowerCase()  === cat.toLowerCase()
  );
  if (yaExiste) {
    alert(`Ya existe un repuesto llamado "${name}" en la categoría "${cat}".\nSi quieres sumar unidades, usa el botón "Stock" de ese repuesto en vez de crear uno nuevo.`);
    return;
  }

  if (qty === 0) {
    const continuar = confirm(`Vas a registrar "${name}" SIN STOCK inicial (0 unidades).\n¿Deseas continuar de todos modos?`);
    if (!continuar) return;
  }

  const id = `REP-${String(repCounter).padStart(3,'0')}`;
  repCounter++;
  stockData.push({ id, name, cat, qty, min, precio });
  closeModal();
  renderStock(stockData);
}

// ===== VENTAS =====
let ventasHoy = [
  { hora:'09:15', client:'Luis Apaza',    detail:'Cambio pantalla Redmi Note 10',   techCode:'TEC-03', monto:320, pago:'Efectivo'   },
  { hora:'10:30', client:'Rosa Ticona',   detail:'Flasheo + firmware',              techCode:'TEC-06', monto:80,  pago:'QR'         },
  { hora:'11:00', client:'—',             detail:'Venta directa: Batería iPhone 11',techCode:'TEC-04', monto:140, pago:'Efectivo'   },
  { hora:'12:45', client:'Hector Mamani', detail:'Pin de carga Motorola G40',       techCode:'TEC-05', monto:120, pago:'Efectivo'   },
  { hora:'14:00', client:'Sandra Cruz',   detail:'Eliminación cuenta Google',       techCode:'TEC-07', monto:50,  pago:'QR'         },
];

function renderVentas() {
  const total = ventasHoy.reduce((a,v)=>a+v.monto,0);
  document.getElementById('ventas-total').textContent = 'Bs '+fmtMonto(total);
  document.getElementById('ventas-count').textContent = ventasHoy.length+' transacciones';
  document.getElementById('ventas-body').innerHTML = ventasHoy.map(v=>`
    <tr>
      <td>${v.hora}</td>
      <td>${v.client}</td>
      <td>${v.detail}</td>
      <td>${getTech(v.techCode).name}</td>
      <td>${v.pago}</td>
      <td style="font-weight:600">Bs ${fmtMonto(v.monto)}</td>
    </tr>`).join('');
}

function registrarVenta() {
  const client = document.getElementById('venta-cliente').value.trim();
  const detail = document.getElementById('venta-detalle').value.trim();
  const monto  = parseFloat(document.getElementById('venta-monto').value)||0;
  const pago   = document.getElementById('venta-pago').value;
  const tech   = document.getElementById('venta-tech').value;
  if (!detail||!monto) { alert('Complete detalle y monto.'); return; }
  ventasHoy.push({ hora:nowTime(), client:client||'—', detail, techCode:tech, monto, pago });
  renderVentas();
  document.getElementById('venta-cliente').value='';
  document.getElementById('venta-detalle').value='';
  document.getElementById('venta-monto').value='';
  alert('✓ Venta registrada correctamente.');
}

// ===== VENTA DE CELULARES =====
let celularesInventario = []; // equipos ingresados: {id, imei, modelo, estado, compra, branch, fechaIngreso, vendido}
let celularesData = [];       // historial de ventas ya realizadas
let celInvCounter = 1;
let celCounter = 1;

// ---- PASO 1: Ingresar equipo al inventario ----
function agregarInventarioCelular() {
  const modelo = document.getElementById('cel-inv-modelo').value.trim();
  const imei   = document.getElementById('cel-inv-imei').value.trim();
  const estado = document.getElementById('cel-inv-estado').value;
  const compra = parseFloat(document.getElementById('cel-inv-compra').value);
  const branch = document.getElementById('cel-inv-branch').value;

  if (!modelo) { alert('Complete la marca y modelo del equipo.'); return; }
  if (!imei || imei.length < 5) { alert('Ingrese un IMEI válido (mínimo 5 dígitos).'); return; }
  if (isNaN(compra) || compra <= 0) { alert('El precio de compra debe ser mayor a 0.'); return; }

  // No permite IMEIs repetidos en el inventario (ni siquiera si el otro ya se vendió, un IMEI es único de por vida)
  const yaExiste = celularesInventario.some(c => c.imei === imei);
  if (yaExiste) {
    alert(`Ya existe un equipo registrado con el IMEI "${imei}" en el inventario.`);
    return;
  }

  celularesInventario.push({
    id: `CELINV-${String(celInvCounter).padStart(3,'0')}`,
    imei, modelo, estado, compra, branch,
    fechaIngreso: nowDate(),
    vendido: false,
  });
  celInvCounter++;

  renderInventarioCelulares(celularesInventario);
  renderCelulares(celularesData); // para refrescar el contador de "En inventario"

  ['cel-inv-modelo','cel-inv-imei','cel-inv-compra'].forEach(id => document.getElementById(id).value = '');
  alert('✓ Equipo agregado al inventario.');
}

function renderInventarioCelulares(data) {
  const disponibles = data.filter(c => !c.vendido);
  const tbody = document.getElementById('inventario-cel-body');

  if (!disponibles.length) {
    tbody.innerHTML = '<tr><td colspan="7" style="text-align:center;color:var(--gray-400);padding:24px">No hay equipos en inventario. Agrega uno arriba.</td></tr>';
  } else {
    tbody.innerHTML = disponibles.map(c => `
      <tr>
        <td>${c.fechaIngreso}</td>
        <td>${c.modelo}</td>
        <td><code class="code-tag" style="font-size:10px">${c.imei}</code></td>
        <td>${c.estado}</td>
        <td>Bs ${fmtMonto(c.compra)}</td>
        <td>${c.branch}</td>
        <td><button class="btn-sm btn-sm-primary" onclick="irAVenderCelular('${c.id}')">Vender</button></td>
      </tr>`).join('');
  }

  populateSelectVentaCelular(disponibles);
  document.getElementById('cel-inventario').textContent = disponibles.length;
}

function filterInventarioCelulares(q) {
  const ql = q.toLowerCase();
  const filtrado = celularesInventario.filter(c => !c.vendido && (
    c.modelo.toLowerCase().includes(ql) || c.imei.toLowerCase().includes(ql)
  ));
  // Renderiza solo la tabla de inventario sin tocar el select global (evita perder la selección)
  const tbody = document.getElementById('inventario-cel-body');
  if (!filtrado.length) {
    tbody.innerHTML = '<tr><td colspan="7" style="text-align:center;color:var(--gray-400);padding:24px">Sin resultados</td></tr>';
    return;
  }
  tbody.innerHTML = filtrado.map(c => `
    <tr>
      <td>${c.fechaIngreso}</td>
      <td>${c.modelo}</td>
      <td><code class="code-tag" style="font-size:10px">${c.imei}</code></td>
      <td>${c.estado}</td>
      <td>Bs ${fmtMonto(c.compra)}</td>
      <td>${c.branch}</td>
      <td><button class="btn-sm btn-sm-primary" onclick="irAVenderCelular('${c.id}')">Vender</button></td>
    </tr>`).join('');
}

// ---- PASO 2: Vender un equipo del inventario ----
function populateSelectVentaCelular(disponibles) {
  const sel = document.getElementById('cel-venta-select');
  const seleccionActual = sel.value;
  sel.innerHTML = '<option value="">— Seleccione un equipo del inventario —</option>' +
    disponibles.map(c => `<option value="${c.id}">${c.modelo} — IMEI ${c.imei}</option>`).join('');
  // mantiene la selección si sigue disponible
  if (disponibles.some(c => c.id === seleccionActual)) sel.value = seleccionActual;
}

function irAVenderCelular(invId) {
  document.getElementById('cel-venta-select').value = invId;
  precargarVentaCelular(invId);
  document.getElementById('card-vender-celular').scrollIntoView({ behavior:'smooth', block:'start' });
}

function precargarVentaCelular(invId) {
  if (!invId) return;
  const equipo = celularesInventario.find(c => c.id === invId);
  if (!equipo) return;
  // Sugerencia de precio de venta con un margen del 20% sobre la compra (solo referencia, editable)
  const sugerido = Math.round(equipo.compra * 1.2);
  document.getElementById('cel-venta').value = sugerido;
}

// Muestra/oculta los campos de cuotas según el método de pago elegido
function toggleCuotasFields() {
  const pago = document.getElementById('cel-pago').value;
  document.getElementById('cel-cuotas-fields').classList.toggle('hidden', pago !== 'Cuotas');
}

function registrarVentaCelular() {
  const invId    = document.getElementById('cel-venta-select').value;
  const cliente  = document.getElementById('cel-cliente').value.trim();
  const telefono = document.getElementById('cel-cliente-tel').value.trim();
  const venta    = parseFloat(document.getElementById('cel-venta').value);
  const pago     = document.getElementById('cel-pago').value;

  if (!invId) { alert('Seleccione un equipo del inventario para vender.'); return; }
  const equipo = celularesInventario.find(c => c.id === invId);
  if (!equipo) { alert('El equipo seleccionado ya no existe en el inventario.'); return; }
  if (equipo.vendido) { alert('Este equipo ya fue vendido anteriormente.'); return; }
  if (!cliente) { alert('El nombre del cliente es obligatorio.'); return; }
  if (isNaN(venta) || venta <= 0) { alert('El precio de venta debe ser mayor a 0.'); return; }

  if (venta < equipo.compra) {
    const continuar = confirm(`Vas a vender "${equipo.modelo}" por Bs ${fmtMonto(venta)}, por DEBAJO de su precio de compra (Bs ${fmtMonto(equipo.compra)}).\n¿Confirmas que quieres registrar esta venta con pérdida?`);
    if (!continuar) return;
  }

  // ===== Si es a Cuotas, validar y armar el plan de pagos =====
  let planPagos = null;
  if (pago === 'Cuotas') {
    if (!telefono) { alert('Para ventas a crédito, el teléfono/CI del cliente es obligatorio (necesario para el contrato y cobranza).'); return; }

    const inicial = parseFloat(document.getElementById('cel-cuotas-inicial').value);
    const numero  = parseInt(document.getElementById('cel-cuotas-numero').value);
    const frecuencia = document.getElementById('cel-cuotas-frecuencia').value;

    if (isNaN(inicial) || inicial < 0) { alert('El pago inicial no puede ser negativo.'); return; }
    if (inicial >= venta) { alert('El pago inicial no puede ser mayor o igual al precio de venta (si no, no es una venta a crédito).'); return; }
    if (isNaN(numero) || numero < 1) { alert('El número de cuotas debe ser al menos 1.'); return; }

    planPagos = generarPlanPagos(venta, inicial, numero, frecuencia);
  }

  // Marca el equipo como vendido (ya no vuelve a aparecer disponible)
  equipo.vendido = true;

  const venta_id = `CEL-${String(celCounter).padStart(3,'0')}`;
  celularesData.push({
    id: venta_id,
    modelo: equipo.modelo,
    imei: equipo.imei,
    estado: equipo.estado,
    cliente,
    telefono: telefono || '—',
    compra: equipo.compra,
    venta,
    pago,
    branch: equipo.branch,
    fecha: nowDate(),
    planPagos, // null si no es a cuotas
  });
  celCounter++;

  renderInventarioCelulares(celularesInventario);
  renderCelulares(celularesData);

  document.getElementById('cel-venta-select').value = '';
  document.getElementById('cel-cliente').value = '';
  document.getElementById('cel-cliente-tel').value = '';
  document.getElementById('cel-venta').value = '';
  document.getElementById('cel-pago').value = 'Efectivo';
  toggleCuotasFields();

  if (pago === 'Cuotas') {
    alert('✓ Venta a crédito registrada. Se generó el plan de pagos y el contrato — puedes verlo/imprimirlo desde el historial.');
    mostrarContrato(venta_id);
  } else {
    alert('✓ Venta de celular registrada correctamente.');
  }
}

// Genera el cronograma de cuotas con fechas según la frecuencia elegida
function generarPlanPagos(total, inicial, numero, frecuencia) {
  const saldo = total - inicial;
  const montoBase = Math.floor((saldo / numero) * 100) / 100;
  const diasPorPeriodo = frecuencia === 'semanal' ? 7 : frecuencia === 'quincenal' ? 15 : 30;

  const cuotas = [];
  let acumulado = 0;
  for (let i = 1; i <= numero; i++) {
    const fecha = new Date();
    fecha.setDate(fecha.getDate() + diasPorPeriodo * i);
    // La última cuota absorbe el redondeo para que la suma cuadre exacto
    const monto = (i === numero) ? Math.round((saldo - acumulado) * 100) / 100 : montoBase;
    acumulado += monto;
    cuotas.push({
      numero: i,
      fecha: fecha.toLocaleDateString('es-BO'),
      monto,
      pagada: false,
    });
  }

  return { total, inicial, saldo, numero, frecuencia, cuotas };
}

// Marca una cuota específica como pagada (o la des-marca si se vuelve a tocar)
function marcarCuotaPagada(ventaId, numeroCuota) {
  const venta = celularesData.find(v => v.id === ventaId);
  if (!venta || !venta.planPagos) return;
  const cuota = venta.planPagos.cuotas.find(c => c.numero === numeroCuota);
  if (!cuota) return;
  cuota.pagada = !cuota.pagada;
  mostrarContrato(ventaId); // refresca la vista con el nuevo estado
}

// ===== CONTRATO DE VENTA A CRÉDITO =====
function mostrarContrato(ventaId) {
  const v = celularesData.find(x => x.id === ventaId);
  if (!v || !v.planPagos) { alert('Esta venta no tiene un plan de pagos asociado.'); return; }
  const p = v.planPagos;

  const filasCuotas = p.cuotas.map(c => `
    <tr>
      <td style="padding:6px 8px;border-bottom:1px solid #f3f4f6">Cuota ${c.numero}</td>
      <td style="padding:6px 8px;border-bottom:1px solid #f3f4f6">${c.fecha}</td>
      <td style="padding:6px 8px;border-bottom:1px solid #f3f4f6;text-align:right">Bs ${fmtMonto(c.monto)}</td>
      <td style="padding:6px 8px;border-bottom:1px solid #f3f4f6;text-align:center">
        <span style="font-size:11px;font-weight:600;color:${c.pagada?'#0e9f6e':'#c27803'}">${c.pagada?'✓ Pagada':'Pendiente'}</span>
      </td>
      <td style="padding:6px 8px;border-bottom:1px solid #f3f4f6;text-align:center">
        <button class="btn-sm" onclick="marcarCuotaPagada('${v.id}', ${c.numero})">${c.pagada?'Desmarcar':'Marcar pagada'}</button>
      </td>
    </tr>`).join('');

  document.getElementById('contrato-cel-preview').innerHTML = `
    <div style="border:2px solid #e5e7eb;border-radius:8px;padding:24px;font-size:13px;line-height:1.8">
      <div style="text-align:center;margin-bottom:16px;border-bottom:2px dashed #e5e7eb;padding-bottom:14px">
        <div style="font-size:22px;font-weight:700;color:#ff1440;letter-spacing:2px">MICEL</div>
        <div style="font-size:11px;color:#6b7280">Contrato de venta a crédito — Equipo móvil</div>
        <div style="font-size:11px;color:#6b7280">Sucursal: ${v.branch} · El Alto, Bolivia</div>
      </div>

      <p style="margin-bottom:10px">
        Por medio del presente documento, <strong>${v.cliente}</strong>
        (Tel./CI: ${v.telefono}) declara adquirir de <strong>MiCel</strong> el equipo detallado a
        continuación, bajo la modalidad de <strong>venta a crédito en cuotas</strong>, comprometiéndose
        a cancelar el saldo pendiente según el cronograma acordado.
      </p>

      <div style="background:#f9fafb;border-radius:6px;padding:12px;margin-bottom:14px">
        <div style="font-size:10px;font-weight:600;color:#9ca3af;text-transform:uppercase;margin-bottom:6px">Datos del equipo</div>
        <div><strong>Modelo:</strong> ${v.modelo}</div>
        <div><strong>IMEI:</strong> ${v.imei}</div>
        <div><strong>Estado:</strong> ${v.estado}</div>
      </div>

      <div style="display:flex;justify-content:space-between;background:#f9fafb;border-radius:6px;padding:12px;margin-bottom:14px">
        <div><strong>Precio total:</strong><br>Bs ${fmtMonto(p.total)}</div>
        <div><strong>Pago inicial:</strong><br>Bs ${fmtMonto(p.inicial)}</div>
        <div><strong>Saldo financiado:</strong><br>Bs ${fmtMonto(p.saldo)}</div>
        <div><strong>Cuotas:</strong><br>${p.numero} (${p.frecuencia})</div>
      </div>

      <div style="font-size:10px;font-weight:600;color:#9ca3af;text-transform:uppercase;margin-bottom:8px">Cronograma de pagos</div>
      <table style="width:100%;border-collapse:collapse;font-size:12px;margin-bottom:16px">
        <thead><tr style="background:#f3f4f6">
          <th style="padding:6px 8px;text-align:left;font-size:11px">Cuota</th>
          <th style="padding:6px 8px;text-align:left;font-size:11px">Vencimiento</th>
          <th style="padding:6px 8px;text-align:right;font-size:11px">Monto</th>
          <th style="padding:6px 8px;text-align:center;font-size:11px">Estado</th>
          <th style="padding:6px 8px;text-align:center;font-size:11px"></th>
        </tr></thead>
        <tbody>${filasCuotas}</tbody>
      </table>

      <div style="background:#fefce8;border:1px solid #fde047;border-radius:6px;padding:12px;font-size:11.5px;color:#713f12;margin-bottom:14px">
        <strong>Cláusulas:</strong> El incumplimiento de 2 o más cuotas consecutivas faculta a MiCel a
        exigir el pago total del saldo pendiente y/o suspender la garantía del equipo. El cliente
        declara haber recibido el equipo en el estado descrito, conforme y en funcionamiento.
      </div>

      <div style="display:flex;justify-content:space-between;margin-top:30px;font-size:12px">
        <div style="text-align:center;width:45%;border-top:1px solid #9ca3af;padding-top:6px">Firma del Cliente</div>
        <div style="text-align:center;width:45%;border-top:1px solid #9ca3af;padding-top:6px">Firma MiCel</div>
      </div>
    </div>`;

  document.getElementById('modal-contrato-cel').classList.remove('hidden');
}

function imprimirContratoCelular() {
  const contenido = document.getElementById('contrato-cel-preview').innerHTML;
  const w = window.open('','_blank');
  w.document.write(`<!DOCTYPE html><html lang="es"><head><meta charset="UTF-8"><title>Contrato MiCel</title>
    <link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>*{box-sizing:border-box;margin:0;padding:0}body{font-family:'DM Sans',sans-serif;padding:30px;max-width:600px;margin:auto;color:#1f2937}@media print{body{padding:10px}button{display:none}}</style>
    </head><body>${contenido}<script>window.onload=()=>window.print()<\/script></body></html>`);
  w.document.close();
}

// ---- Historial de ventas ----
function renderCelulares(data) {
  const vendidos  = data.length;
  const ingresos  = data.reduce((a,c)=>a+c.venta, 0);
  const ganancia  = data.reduce((a,c)=>a+(c.venta - c.compra), 0);

  document.getElementById('cel-vendidos').textContent  = vendidos;
  document.getElementById('cel-ingresos').textContent  = 'Bs ' + fmtMonto(ingresos);
  document.getElementById('cel-ganancia').textContent  = 'Bs ' + fmtMonto(ganancia);
  document.getElementById('cel-inventario').textContent = celularesInventario.filter(c=>!c.vendido).length;

  const tbody = document.getElementById('celulares-body');
  if (!data.length) {
    tbody.innerHTML = '<tr><td colspan="9" style="text-align:center;color:var(--gray-400);padding:24px">No se han registrado ventas de celulares aún</td></tr>';
    return;
  }

  tbody.innerHTML = [...data].reverse().map(c => `
    <tr>
      <td>${c.fecha}</td>
      <td>${c.modelo}</td>
      <td><code class="code-tag" style="font-size:10px">${c.imei||'—'}</code></td>
      <td>${c.estado}</td>
      <td>${c.cliente||'—'}</td>
      <td>Bs ${fmtMonto(c.compra)}</td>
      <td style="font-weight:600">Bs ${fmtMonto(c.venta)}</td>
      <td style="font-weight:600;color:${(c.venta-c.compra)>=0?'var(--success)':'var(--danger)'}">Bs ${fmtMonto(c.venta-c.compra)}</td>
      <td>${c.branch}</td>
      <td>${c.pago}</td>
      <td>${c.planPagos ? `<button class="btn-sm btn-sm-primary" onclick="mostrarContrato('${c.id}')">Contrato</button>` : ''}</td>
    </tr>`).join('');
}

function filterCelulares(q) {
  const ql = q.toLowerCase();
  renderCelulares(celularesData.filter(c =>
    c.modelo.toLowerCase().includes(ql) ||
    (c.imei||'').toLowerCase().includes(ql) ||
    (c.cliente||'').toLowerCase().includes(ql)
  ));
}

// ===== CLIENTES =====
function renderClientes(data) {
  document.getElementById('clientes-body').innerHTML = data.map(c=>`
    <tr>
      <td><code class="code-tag" style="font-size:10px">${c.id}</code></td>
      <td>${c.name}</td>
      <td>${c.phone}</td>
      <td>${c.visits}</td>
      <td>${c.lastVisit}</td>
      <td>${c.branch}</td>
      <td>
        <button class="btn-sm btn-sm-primary" onclick="verRecibosCliente('${c.name}')">Recibos</button>
      </td>
    </tr>`).join('');
}

function filterClientes(q) {
  renderClientes(clientesData.filter(c=>
    c.name.toLowerCase().includes(q.toLowerCase()) ||
    c.phone.includes(q)
  ));
}

function guardarCliente() {
  const name  = document.getElementById('new-cli-name').value.trim();
  const phone = document.getElementById('new-cli-phone').value.trim();
  const branch= document.getElementById('new-cli-branch').value;
  if (!name||!phone) { alert('Complete nombre y teléfono.'); return; }
  const id = `CLI-${String(cliCounter).padStart(3,'0')}`;
  cliCounter++;
  clientesData.push({ id, name, phone, branch, visits:0, lastVisit:nowDate() });
  closeModal();
  renderClientes(clientesData);
}

function verRecibosCliente(nombre) {
  const recs = recibosData.filter(r=>r.cliente===nombre);
  if (recs.length===0) { alert(`El cliente "${nombre}" no tiene recibos generados aún.`); return; }
  if (recs.length===1) { mostrarVistaPrevia(recs[0]); return; }
  const lista = recs.map((r,i)=>`${i+1}. ${r.numRecibo} — ${r.servicio} — Bs ${fmtMonto(r.monto)} — ${r.fecha}`).join('\n');
  alert(`Recibos de ${nombre}:\n\n${lista}\n\nSe mostrará el más reciente.`);
  mostrarVistaPrevia(recs[recs.length-1]);
}

// ===== USUARIOS =====
function renderUsers() {
  document.getElementById('users-body').innerHTML = tecnicos.map(t=>`
    <tr>
      <td><code class="code-tag">${t.code}</code></td>
      <td><div class="avatar-cell"><div class="avatar">${initials(t.name)}</div>${t.name}</div></td>
      <td style="font-family:var(--font-mono);font-size:12px;color:var(--gray-400)">${t.user}</td>
      <td>${t.rol==='Administrador'?'<span class="badge badge-purple">Administrador</span>':'<span class="badge badge-amber">Técnico</span>'}</td>
      <td>${t.branch}</td>
      <td><span class="badge ${t.active?'badge-green':'badge-red'}">${t.active?'Activo':'Inactivo'}</span></td>
    </tr>`).join('');
}

// ===== REPORTES =====
const reporteTecnicos = [
  {techCode:'TEC-03',ordenes:14,ingresos:2520},{techCode:'TEC-04',ordenes:11,ingresos:1980},
  {techCode:'TEC-05',ordenes:9, ingresos:1620},{techCode:'TEC-06',ordenes:13,ingresos:2340},
  {techCode:'TEC-07',ordenes:7, ingresos:1260},{techCode:'TEC-08',ordenes:5, ingresos:900 },
  {techCode:'TEC-09',ordenes:8, ingresos:1440},{techCode:'TEC-10',ordenes:0, ingresos:0   },
];

function renderReportTech() {
  document.getElementById('report-tech-body').innerHTML = reporteTecnicos.map(r=>{
    const t=getTech(r.techCode);
    return `<tr>
      <td><code class="code-tag">${t.code}</code></td>
      <td><div class="avatar-cell"><div class="avatar">${initials(t.name)}</div>${t.name}</div></td>
      <td>${r.ordenes}</td>
      <td style="font-weight:600">Bs ${fmtMonto(r.ingresos)}</td>
      <td>${t.branch}</td>
    </tr>`;
  }).join('');
}

// ===== RECIBOS =====
function populateReciboOrden() {
  const sel = document.getElementById('recibo-orden');
  if (!sel) return;
  sel.innerHTML = '<option value="">— Seleccione una orden —</option>' +
    ordersData.map(o=>`<option value="${o.code}">${o.code} — ${o.client} · ${o.device}</option>`).join('');
}

function precargarRecibo(code) {
  if (!code) return;
  const o = ordersData.find(x=>x.code===code);
  if (!o) return;
  document.getElementById('recibo-cliente').value  = o.client;
  document.getElementById('recibo-telefono').value = o.phone||'';
  document.getElementById('recibo-equipo').value   = o.device;
  document.getElementById('recibo-servicio').value = o.service;
  document.getElementById('recibo-monto').value    = o.monto||'';
  document.getElementById('recibo-obs').value      = o.obs||'Garantía de 30 días por el servicio realizado.';
  const ts = document.getElementById('recibo-tech');
  if (ts) for(let i=0;i<ts.options.length;i++) if(ts.options[i].value===o.techCode){ts.selectedIndex=i;break;}
  const ss = document.getElementById('recibo-sucursal');
  if (ss) for(let i=0;i<ss.options.length;i++) if(o.branch.includes(ss.options[i].text)){ss.selectedIndex=i;break;}
}

function generarRecibo() {
  const numRecibo = document.getElementById('recibo-num').value.trim() ||
    `REC-${String(reciboCounter).padStart(4,'0')}`;
  const cliente  = document.getElementById('recibo-cliente').value.trim();
  const telefono = document.getElementById('recibo-telefono').value.trim();
  const equipo   = document.getElementById('recibo-equipo').value.trim();
  const servicio = document.getElementById('recibo-servicio').value.trim();
  const monto    = parseFloat(document.getElementById('recibo-monto').value)||0;
  const pago     = document.getElementById('recibo-pago').value;
  let techCode = document.getElementById('recibo-tech').value;
  if (currentUser && currentUser.rol === 'Técnico') techCode = currentUser.techCode;
  const sucursal = document.getElementById('recibo-sucursal').value;
  const obs      = document.getElementById('recibo-obs').value.trim();
  const tipo     = document.getElementById('recibo-tipo').value;
  const orden    = document.getElementById('recibo-orden').value || '—';
  if (!cliente||!equipo||!servicio||!monto) { alert('Complete: Cliente, Equipo, Servicio y Monto.'); return; }
  if (recibosData.find(r=>r.numRecibo===numRecibo)) {
    alert(`Ya existe el recibo ${numRecibo}. Cambie el número o deje vacío para generar automáticamente.`);
    return;
  }
  const recibo = { numRecibo, orden, cliente, telefono, equipo, servicio, monto, pago, techCode, sucursal, obs, tipo, hora:nowTime(), fecha:nowDate() };
  recibosData.push(recibo);
  if (!document.getElementById('recibo-num').value.trim()) reciboCounter++;
  renderRecibosHistorial();
  populateReciboOrden();
  limpiarFormRecibo();
  mostrarVistaPrevia(recibo);
}

function renderRecibosHistorial() {
  const tbody = document.getElementById('recibos-body');
  const count = document.getElementById('recibo-count');
  if (count) count.textContent = `${recibosData.length} recibo${recibosData.length!==1?'s':''}`;
  if (!recibosData.length) {
    tbody.innerHTML = '<tr><td colspan="9" style="text-align:center;color:var(--gray-400);padding:24px">No se han generado recibos aún</td></tr>';
    return;
  }
  tbody.innerHTML = [...recibosData].reverse().map(r=>`
    <tr>
      <td><code class="code-tag">${r.numRecibo}</code></td>
      <td><code class="code-tag" style="font-size:10px">${r.orden}</code></td>
      <td>${r.cliente}</td>
      <td>${r.servicio}</td>
      <td style="font-weight:600">Bs ${fmtMonto(r.monto)}</td>
      <td>${r.pago}</td>
      <td>${getTech(r.techCode).name}</td>
      <td>${r.hora}</td>
      <td style="display:flex;gap:4px">
        <button class="btn-sm" onclick='editarRecibo("${r.numRecibo}")'>Editar</button>
        <button class="btn-sm btn-sm-primary" onclick='mostrarVistaPrevia(${JSON.stringify(r)})'>Ver</button>
      </td>
    </tr>`).join('');
}

function mostrarVistaPrevia(recibo) {
  const tech = getTech(recibo.techCode);
  document.getElementById('recibo-preview').innerHTML = `
    <div style="border:2px solid #e5e7eb;border-radius:8px;padding:24px;font-size:13px;line-height:1.9">
      <div style="text-align:center;margin-bottom:18px;border-bottom:2px dashed #e5e7eb;padding-bottom:16px">
        <div style="font-size:24px;font-weight:700;color:#ff1440;letter-spacing:2px">MICEL</div>
        <div style="font-size:11px;color:#6b7280">Servicio técnico especializado en dispositivos móviles</div>
        <div style="font-size:11px;color:#6b7280">Sucursal: ${recibo.sucursal} · El Alto, Bolivia</div>
        <div style="font-size:11px;color:#6b7280">Tel: 13245698 · miceltech@gmail.com</div>
      </div>
      <div style="display:flex;justify-content:space-between;margin-bottom:16px">
        <div>
          <div style="font-size:10px;color:#9ca3af;text-transform:uppercase;font-weight:600;letter-spacing:.05em">${recibo.tipo}</div>
          <div style="font-size:20px;font-weight:700;color:#111827">${recibo.numRecibo}</div>
        </div>
        <div style="text-align:right;font-size:12px">
          <div style="color:#9ca3af">Fecha: <strong style="color:#374151">${recibo.fecha}</strong></div>
          <div style="color:#9ca3af">Hora: <strong style="color:#374151">${recibo.hora}</strong></div>
          <div style="color:#9ca3af">Orden: <strong style="color:#374151">${recibo.orden}</strong></div>
        </div>
      </div>
      <div style="background:#f9fafb;border-radius:6px;padding:12px;margin-bottom:14px">
        <div style="font-size:10px;font-weight:600;color:#9ca3af;text-transform:uppercase;margin-bottom:8px">Datos del cliente</div>
        <div><strong>Cliente:</strong> ${recibo.cliente}</div>
        ${recibo.telefono&&recibo.telefono!=='—'?`<div><strong>Teléfono:</strong> ${recibo.telefono}</div>`:''}
        <div><strong>Equipo:</strong> ${recibo.equipo}</div>
      </div>
      <div style="margin-bottom:14px">
        <div style="font-size:10px;font-weight:600;color:#9ca3af;text-transform:uppercase;margin-bottom:8px">Detalle del servicio</div>
        <table style="width:100%;border-collapse:collapse;font-size:13px">
          <thead><tr style="background:#f3f4f6">
            <th style="padding:8px;text-align:left;font-size:11px;border-radius:4px 0 0 0">Descripción</th>
            <th style="padding:8px;text-align:right;font-size:11px;border-radius:0 4px 0 0">Importe</th>
          </tr></thead>
          <tbody><tr>
            <td style="padding:10px 8px;border-bottom:1px solid #f3f4f6">${recibo.servicio}</td>
            <td style="padding:10px 8px;text-align:right;border-bottom:1px solid #f3f4f6">Bs ${fmtMonto(recibo.monto)}</td>
          </tr></tbody>
          <tfoot><tr style="font-weight:700">
            <td style="padding:10px 8px;color:#ff1440;font-size:14px">TOTAL</td>
            <td style="padding:10px 8px;text-align:right;font-size:18px;color:#ff1440">Bs ${fmtMonto(recibo.monto)}</td>
          </tr></tfoot>
        </table>
      </div>
      <div style="display:flex;justify-content:space-between;font-size:12px;color:#4b5563;margin-bottom:12px;background:#f9fafb;padding:10px;border-radius:6px">
        <div>💳 <strong>Pago:</strong> ${recibo.pago}</div>
        <div>🔧 <strong>Técnico:</strong> ${tech.name} (${tech.code})</div>
      </div>
      ${recibo.obs?`<div style="background:#fefce8;border:1px solid #fde047;border-radius:6px;padding:10px;font-size:12px;color:#713f12;margin-bottom:14px">⚠️ <strong>Garantía / Nota:</strong> ${recibo.obs}</div>`:''}
      <div style="text-align:center;border-top:2px dashed #e5e7eb;padding-top:14px;font-size:11px;color:#9ca3af">
        Gracias por su confianza en MiCel 🙏<br>
        Conserve este recibo como comprobante del servicio realizado.
      </div>
    </div>`;
  document.getElementById('modal-recibo').classList.remove('hidden');
}

function imprimirRecibo() {
  const contenido = document.getElementById('recibo-preview').innerHTML;
  const w = window.open('','_blank');
  w.document.write(`<!DOCTYPE html><html lang="es"><head><meta charset="UTF-8"><title>Recibo MiCel</title>
    <link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>*{box-sizing:border-box;margin:0;padding:0}body{font-family:'DM Sans',sans-serif;padding:30px;max-width:500px;margin:auto;color:#1f2937}@media print{body{padding:10px}}</style>
    </head><body>${contenido}<script>window.onload=()=>window.print()<\/script></body></html>`);
  w.document.close();
}

function limpiarFormRecibo() {
  ['recibo-num','recibo-cliente','recibo-telefono','recibo-equipo','recibo-servicio','recibo-monto','recibo-obs'].forEach(id=>{
    const el=document.getElementById(id); if(el) el.value='';
  });
  const so=document.getElementById('recibo-orden'); if(so) so.selectedIndex=0;
}

// ===== MODALES =====
function openModal(tipo) {
  document.querySelectorAll('.modal-overlay').forEach(m=>m.classList.add('hidden'));
  const map = {
    'orden':          'modal',
    'editar-orden':   'modal-editar-orden',
    'repuesto':       'modal-repuesto',
    'editar-repuesto':'modal-editar-repuesto',
    'ajuste-stock':   'modal-ajuste-stock',
    'venta':          'modal-venta',
    'cliente':        'modal-cliente',
    'recibo-manual':  'modal-recibo',
    'estado-orden':    'modal-estado',
    'editar-recibo':   'modal-editar-recibo',
  };
  const id = map[tipo];
  if (id) document.getElementById(id).classList.remove('hidden');
}

function closeModal() {
  document.querySelectorAll('.modal-overlay').forEach(m=>m.classList.add('hidden'));
}

document.addEventListener('click', e => {
  if (e.target.classList.contains('modal-overlay')) closeModal();
});

// ===== CAMBIO RÁPIDO DE ESTADO DESDE LA TABLA =====
function cambiarEstado(code) {
  const o = ordersData.find(x => x.code === code);
  if (!o) return;
  document.getElementById('estado-order-code').textContent = o.code;
  document.getElementById('estado-order-info').textContent = `${o.client} · ${o.device}`;
  document.getElementById('estado-hidden-code').value = o.code;
  const ss = document.getElementById('estado-select');
  for (let i = 0; i < ss.options.length; i++) {
    if (ss.options[i].value === o.status) { ss.selectedIndex = i; break; }
  }
  document.getElementById('modal-estado').classList.remove('hidden');
}

function guardarEstado() {
  const code   = document.getElementById('estado-hidden-code').value;
  const status = document.getElementById('estado-select').value;
  const idx    = ordersData.findIndex(x => x.code === code);
  if (idx < 0) return;
  ordersData[idx].status = status;
  closeModal();
  renderOrders(ordersData);
  renderDashOrders();
}

// ===== EDITAR RECIBO YA GENERADO =====
function editarRecibo(numRecibo) {
  const r = recibosData.find(x => x.numRecibo === numRecibo);
  if (!r) return;

  document.getElementById('edit-rec-num-display').textContent = numRecibo;
  document.getElementById('edit-rec-num').value       = r.numRecibo;
  document.getElementById('edit-rec-cliente').value   = r.cliente;
  document.getElementById('edit-rec-telefono').value  = r.telefono || '';
  document.getElementById('edit-rec-equipo').value    = r.equipo;
  document.getElementById('edit-rec-servicio').value  = r.servicio;
  document.getElementById('edit-rec-monto').value     = r.monto;
  document.getElementById('edit-rec-obs').value       = r.obs || '';

  const ps = document.getElementById('edit-rec-pago');
  for (let i = 0; i < ps.options.length; i++) {
    if (ps.options[i].value === r.pago) { ps.selectedIndex = i; break; }
  }
  const ss = document.getElementById('edit-rec-sucursal');
  for (let i = 0; i < ss.options.length; i++) {
    if (r.sucursal && r.sucursal.includes(ss.options[i].text)) { ss.selectedIndex = i; break; }
  }
  const ts = document.getElementById('edit-rec-tech');
  ts.innerHTML = tecnicos.filter(t => t.active)
    .map(t => `<option value="${t.code}" ${t.code === r.techCode ? 'selected' : ''}>${t.code} — ${t.name}</option>`)
    .join('');

  document.getElementById('modal-editar-recibo').classList.remove('hidden');
}

function guardarEdicionRecibo() {
  const numRecibo = document.getElementById('edit-rec-num').value;
  const idx = recibosData.findIndex(x => x.numRecibo === numRecibo);
  if (idx < 0) return;

  recibosData[idx].cliente   = document.getElementById('edit-rec-cliente').value.trim();
  recibosData[idx].telefono  = document.getElementById('edit-rec-telefono').value.trim();
  recibosData[idx].equipo    = document.getElementById('edit-rec-equipo').value.trim();
  recibosData[idx].servicio  = document.getElementById('edit-rec-servicio').value.trim();
  recibosData[idx].monto     = parseFloat(document.getElementById('edit-rec-monto').value) || 0;
  recibosData[idx].pago      = document.getElementById('edit-rec-pago').value;
  recibosData[idx].techCode  = document.getElementById('edit-rec-tech').value;
  recibosData[idx].sucursal  = document.getElementById('edit-rec-sucursal').value;
  recibosData[idx].obs       = document.getElementById('edit-rec-obs').value.trim();

  closeModal();
  renderRecibosHistorial();
}