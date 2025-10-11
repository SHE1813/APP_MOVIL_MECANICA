import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Taller Mecánico',
      theme: ThemeData(primaryColor: Colors.orange),
      home: MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Cliente {
  String id;
  String nombre;
  String telefono;
  String vehiculo;
  String placa;
  String marca;
  String problema;
  String estado;

  Cliente({
    required this.id,
    required this.nombre,
    required this.telefono,
    required this.vehiculo,
    required this.placa,
    required this.marca,
    required this.problema,
    this.estado = 'En espera',
  });

  Map<String, dynamic> toJson() => {
    'id': id, 'nombre': nombre, 'telefono': telefono,
    'vehiculo': vehiculo, 'placa': placa, 'marca': marca,
    'problema': problema, 'estado': estado,
  };

  factory Cliente.fromJson(Map<String, dynamic> json) => Cliente(
    id: json['id'], nombre: json['nombre'], telefono: json['telefono'],
    vehiculo: json['vehiculo'], placa: json['placa'], marca: json['marca'],
    problema: json['problema'], estado: json['estado'] ?? 'En espera',
  );
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int indice = 0;
  List<String> carrito = [];

  @override
  void initState() {
    super.initState();
    cargarCarrito();
  }

  void cargarCarrito() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      carrito = prefs.getStringList('carrito') ?? [];
    });
  }

  void guardarCarrito() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('carrito', carrito);
  }

  void agregarAlCarrito(String servicio) {
    setState(() {
      carrito.add(servicio);
    });
    guardarCarrito();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$servicio agregado 🔧'), backgroundColor: Colors.orange),
    );
  }

  void eliminarDelCarrito(int index) {
    setState(() {
      carrito.removeAt(index);
    });
    guardarCarrito();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> pantallas = [
      ServiciosScreen(onAgregar: agregarAlCarrito),
      CotizacionScreen(servicios: carrito, onEliminar: eliminarDelCarrito),
      ContactoScreen(),
      ClientesScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          ['Servicios', 'Cotización', 'Contacto', 'Clientes'][indice],
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.orange.shade700,
      ),
      body: pantallas[indice],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: indice,
        onTap: (i) => setState(() => indice = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.orange.shade700,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.build), label: 'Servicios'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Cotización'),
          BottomNavigationBarItem(icon: Icon(Icons.phone), label: 'Contacto'),
          BottomNavigationBarItem(icon: Icon(Icons.directions_car), label: 'Clientes'),
        ],
      ),
    );
  }
}

class ServiciosScreen extends StatelessWidget {
  final Function(String) onAgregar;
  ServiciosScreen({required this.onAgregar});

  final List<Map<String, dynamic>> servicios = [
    {'nombre': 'Cambio de Aceite', 'precio': 'S/ 80', 'icono': Icons.opacity, 'color': Colors.blue},
    {'nombre': 'Alineamiento', 'precio': 'S/ 60', 'icono': Icons.album, 'color': Colors.purple},
    {'nombre': 'Cambio de Frenos', 'precio': 'S/ 150', 'icono': Icons.disc_full, 'color': Colors.red},
    {'nombre': 'Revisión General', 'precio': 'S/ 50', 'icono': Icons.search, 'color': Colors.green},
    {'nombre': 'Cambio de Batería', 'precio': 'S/ 200', 'icono': Icons.battery_charging_full, 'color': Colors.amber},
    {'nombre': 'Escaneo Computarizado', 'precio': 'S/ 70', 'icono': Icons.computer, 'color': Colors.indigo},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade50, Colors.white],
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                Text('🔧 TALLER SPEED AUTO 🚗', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.orange.shade800)),
                SizedBox(height: 8),
                Text('Servicios profesionales para tu vehículo', style: TextStyle(color: Colors.grey.shade600)),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(12),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 1.1, crossAxisSpacing: 10, mainAxisSpacing: 10),
              itemCount: servicios.length,
              itemBuilder: (context, i) {
                return Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: InkWell(
                    onTap: () => onAgregar(servicios[i]['nombre']),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: EdgeInsets.all(8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(servicios[i]['icono'], size: 32, color: servicios[i]['color']),
                          SizedBox(height: 8),
                          Text(servicios[i]['nombre'], textAlign: TextAlign.center, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, height: 1.1), maxLines: 2),
                          SizedBox(height: 4),
                          Text(servicios[i]['precio'], style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orange.shade700)),
                          SizedBox(height: 6),
                          Container(
                            height: 28,
                            child: ElevatedButton(
                              onPressed: () => onAgregar(servicios[i]['nombre']),
                              style: ElevatedButton.styleFrom(backgroundColor: servicios[i]['color'], padding: EdgeInsets.symmetric(horizontal: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                              child: Text('Agregar', style: TextStyle(color: Colors.white, fontSize: 11)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class CotizacionScreen extends StatelessWidget {
  final List<String> servicios;
  final Function(int) onEliminar;
  CotizacionScreen({required this.servicios, required this.onEliminar});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.orange.shade50, Colors.white])),
      child: servicios.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long, size: 100, color: Colors.grey.shade400),
                  SizedBox(height: 20),
                  Text('No hay servicios en la cotización', style: TextStyle(fontSize: 18, color: Colors.grey.shade600)),
                  SizedBox(height: 10),
                  Text('¡Agrega servicios desde el catálogo!', style: TextStyle(fontSize: 14, color: Colors.grey)),
                ],
              ),
            )
          : Column(
              children: [
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.orange.shade700, borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30))),
                  child: Column(
                    children: [
                      Text('📋 COTIZACIÓN', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                      SizedBox(height: 10),
                      Text('Servicios seleccionados: ${servicios.length}', style: TextStyle(color: Colors.white, fontSize: 16)),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.all(12),
                    itemCount: servicios.length,
                    itemBuilder: (context, i) {
                      return Card(
                        elevation: 3,
                        margin: EdgeInsets.symmetric(vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: CircleAvatar(backgroundColor: Colors.orange.shade100, child: Icon(Icons.build, color: Colors.orange.shade700)),
                          title: Text(servicios[i], style: TextStyle(fontWeight: FontWeight.bold)),
                          trailing: IconButton(icon: Icon(Icons.delete, color: Colors.red), onPressed: () => onEliminar(i)),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 10, offset: Offset(0, -5))]),
                  child: Column(
                    children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text('Total de servicios:', style: TextStyle(fontSize: 16)),
                        Text('${servicios.length}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orange.shade700)),
                      ]),
                      SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('¡Cotización enviada! 🚗'), backgroundColor: Colors.green)),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade700, padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25))),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.send, color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text('Enviar Cotización', style: TextStyle(fontSize: 14, color: Colors.white)),
                        ]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class ContactoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.orange.shade50, Colors.white])),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Container(padding: EdgeInsets.all(30), decoration: BoxDecoration(color: Colors.orange.shade700, shape: BoxShape.circle), child: Icon(Icons.garage, size: 80, color: Colors.white)),
            SizedBox(height: 20),
            Text('TALLER SPEED AUTO', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.orange.shade800)),
            Text('Tu confianza, nuestra experiencia', style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
            SizedBox(height: 40),
            _buildContactCard(Icons.location_on, 'Dirección', 'Av. Industrial 456, Huancayo', Colors.red),
            SizedBox(height: 15),
            _buildContactCard(Icons.phone, 'Teléfono', '+51 964 555 777', Colors.green),
            SizedBox(height: 15),
            _buildContactCard(Icons.email, 'Email', 'contacto@speedauto.com', Colors.blue),
            SizedBox(height: 15),
            _buildContactCard(Icons.access_time, 'Horario', 'Lun - Sab: 8:00 AM - 7:00 PM', Colors.orange),
            SizedBox(height: 30),
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.orange.shade100, borderRadius: BorderRadius.circular(15)),
              child: Column(
                children: [
                  Icon(Icons.star, color: Colors.orange.shade700, size: 40),
                  SizedBox(height: 10),
                  Text('¡Atención 24/7 para emergencias!', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orange.shade900)),
                  Text('Servicio de grúa disponible', style: TextStyle(color: Colors.grey.shade700)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard(IconData icon, String title, String info, Color color) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 8, offset: Offset(0, 3))]),
      child: Row(
        children: [
          Container(padding: EdgeInsets.all(12), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 30)),
          SizedBox(width: 15),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              SizedBox(height: 4),
              Text(info, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ]),
          ),
        ],
      ),
    );
  }
}

class ClientesScreen extends StatefulWidget {
  @override
  _ClientesScreenState createState() => _ClientesScreenState();
}

class _ClientesScreenState extends State<ClientesScreen> {
  List<Cliente> clientes = [];

  @override
  void initState() {
    super.initState();
    cargarClientes();
  }

  void cargarClientes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? clientesJson = prefs.getString('clientes');
    if (clientesJson != null) {
      List<dynamic> lista = jsonDecode(clientesJson);
      setState(() {
        clientes = lista.map((c) => Cliente.fromJson(c)).toList();
      });
    }
  }

  void guardarClientes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('clientes', jsonEncode(clientes.map((c) => c.toJson()).toList()));
  }

  void agregarCliente(Cliente cliente) {
    setState(() => clientes.add(cliente));
    guardarClientes();
  }

  void editarCliente(int index, Cliente cliente) {
    setState(() => clientes[index] = cliente);
    guardarClientes();
  }

  void eliminarCliente(int index) {
    setState(() => clientes.removeAt(index));
    guardarClientes();
  }

  Color getEstadoColor(String estado) {
    switch (estado) {
      case 'En espera': return Colors.orange;
      case 'En reparación': return Colors.blue;
      case 'Listo': return Colors.green;
      case 'Entregado': return Colors.grey;
      default: return Colors.orange;
    }
  }

  void mostrarFormulario({Cliente? cliente, int? index}) {
    final nombreCtrl = TextEditingController(text: cliente?.nombre ?? '');
    final telefonoCtrl = TextEditingController(text: cliente?.telefono ?? '');
    final vehiculoCtrl = TextEditingController(text: cliente?.vehiculo ?? '');
    final placaCtrl = TextEditingController(text: cliente?.placa ?? '');
    final marcaCtrl = TextEditingController(text: cliente?.marca ?? '');
    final problemaCtrl = TextEditingController(text: cliente?.problema ?? '');
    String estadoSeleccionado = cliente?.estado ?? 'En espera';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(children: [Icon(Icons.directions_car, color: Colors.orange.shade700), SizedBox(width: 10), Text(cliente == null ? 'Nuevo Cliente' : 'Editar Cliente')]),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: nombreCtrl, decoration: InputDecoration(labelText: 'Nombre del Cliente', prefixIcon: Icon(Icons.person), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
            SizedBox(height: 12),
            TextField(controller: telefonoCtrl, decoration: InputDecoration(labelText: 'Teléfono', prefixIcon: Icon(Icons.phone), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))), keyboardType: TextInputType.phone),
            SizedBox(height: 12),
            TextField(controller: vehiculoCtrl, decoration: InputDecoration(labelText: 'Tipo de Vehículo', prefixIcon: Icon(Icons.car_rental), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
            SizedBox(height: 12),
            TextField(controller: marcaCtrl, decoration: InputDecoration(labelText: 'Marca', prefixIcon: Icon(Icons.branding_watermark), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
            SizedBox(height: 12),
            TextField(controller: placaCtrl, decoration: InputDecoration(labelText: 'Placa', prefixIcon: Icon(Icons.credit_card), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
            SizedBox(height: 12),
            TextField(controller: problemaCtrl, decoration: InputDecoration(labelText: 'Problema/Servicio', prefixIcon: Icon(Icons.build), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))), maxLines: 2),
            SizedBox(height: 12),
            StatefulBuilder(builder: (context, setStateDialog) {
              return DropdownButtonFormField<String>(
                value: estadoSeleccionado,
                decoration: InputDecoration(labelText: 'Estado', prefixIcon: Icon(Icons.traffic), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                items: ['En espera', 'En reparación', 'Listo', 'Entregado'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (value) => setStateDialog(() => estadoSeleccionado = value!),
              );
            }),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              if (nombreCtrl.text.isNotEmpty && placaCtrl.text.isNotEmpty) {
                Cliente nuevoCliente = Cliente(
                  id: cliente?.id ?? DateTime.now().toString(),
                  nombre: nombreCtrl.text, telefono: telefonoCtrl.text, vehiculo: vehiculoCtrl.text,
                  placa: placaCtrl.text, marca: marcaCtrl.text, problema: problemaCtrl.text, estado: estadoSeleccionado,
                );
                cliente == null ? agregarCliente(nuevoCliente) : editarCliente(index!, nuevoCliente);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(cliente == null ? 'Cliente agregado 🚗' : 'Cliente actualizado 🔧'), backgroundColor: Colors.orange.shade700));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade700),
            child: Text('Guardar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.orange.shade50, Colors.white])),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Vehículos Registrados', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text('${clientes.length} clientes', style: TextStyle(color: Colors.grey)),
              ]),
              FloatingActionButton(onPressed: () => mostrarFormulario(), backgroundColor: Colors.orange.shade700, child: Icon(Icons.add, color: Colors.white)),
            ]),
          ),
          Expanded(
            child: clientes.isEmpty
                ? Center(
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.directions_car_outlined, size: 100, color: Colors.grey.shade400),
                      SizedBox(height: 20),
                      Text('No hay vehículos registrados', style: TextStyle(fontSize: 18, color: Colors.grey.shade600)),
                      SizedBox(height: 10),
                      Text('Toca el botón + para agregar', style: TextStyle(color: Colors.grey)),
                    ]),
                  )
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    itemCount: clientes.length,
                    itemBuilder: (context, i) {
                      return Card(
                        elevation: 3,
                        margin: EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        child: Container(
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), border: Border(left: BorderSide(color: getEstadoColor(clientes[i].estado), width: 5))),
                          child: Padding(
                            padding: EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(children: [
                                  CircleAvatar(backgroundColor: Colors.orange.shade100, radius: 25, child: Icon(Icons.directions_car, color: Colors.orange.shade700, size: 28)),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      Text(clientes[i].nombre, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                      Text('${clientes[i].marca} - ${clientes[i].vehiculo}', style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                                    ]),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(color: getEstadoColor(clientes[i].estado).withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                                    child: Text(clientes[i].estado, style: TextStyle(color: getEstadoColor(clientes[i].estado), fontWeight: FontWeight.bold, fontSize: 12)),
                                  ),
                                ]),
                                Divider(height: 20),
                                Row(children: [Icon(Icons.credit_card, size: 16, color: Colors.grey), SizedBox(width: 8), Text('Placa: ${clientes[i].placa}', style: TextStyle(fontSize: 14))]),
                                SizedBox(height: 6),
                                Row(children: [Icon(Icons.phone, size: 16, color: Colors.grey), SizedBox(width: 8), Text('Tel: ${clientes[i].telefono}', style: TextStyle(fontSize: 14))]),
                                SizedBox(height: 6),
                                Row(children: [Icon(Icons.build, size: 16, color: Colors.grey), SizedBox(width: 8), Expanded(child: Text('Servicio: ${clientes[i].problema}', style: TextStyle(fontSize: 14)))]),
                                SizedBox(height: 12),
                                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                                  TextButton.icon(onPressed: () => mostrarFormulario(cliente: clientes[i], index: i), icon: Icon(Icons.edit, size: 18), label: Text('Editar'), style: TextButton.styleFrom(foregroundColor: Colors.blue)),
                                  SizedBox(width: 8),
                                  TextButton.icon(
                                    onPressed: () => showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: Text('Eliminar Cliente'),
                                        content: Text('¿Estás seguro de eliminar el vehículo ${clientes[i].placa}?'),
                                        actions: [
                                          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancelar')),
                                          ElevatedButton(
                                            onPressed: () {
                                              eliminarCliente(i);
                                              Navigator.pop(context);
                                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Cliente eliminado'), backgroundColor: Colors.red));
                                            },
                                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                            child: Text('Eliminar', style: TextStyle(color: Colors.white)),
                                          ),
                                        ],
                                      ),
                                    ),
                                    icon: Icon(Icons.delete, size: 18),
                                    label: Text('Eliminar'),
                                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                                  ),
                                ]),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
