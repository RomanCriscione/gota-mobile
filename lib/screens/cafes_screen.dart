import 'package:flutter/material.dart';
import 'cafe_detail_screen.dart';
import '../models/cafe.dart';
import '../services/api_service.dart';
import 'cafes_map_screen.dart';
import '../services/app_state.dart';

class CafesScreen extends StatefulWidget {
  const CafesScreen({super.key});

  @override
  State<CafesScreen> createState() => _CafesScreenState();
}

class _CafesScreenState extends State<CafesScreen> {
  late Future<List<Cafe>> cafesFuture;

  bool filtroWifi = false;
  bool filtroEnchufes = false;
  bool filtroEspecialidad = false;
  bool filtroLaptop = false;
  bool filtroMascotas = false;
  bool filtroBrunch = false;
  bool filtroDesayuno = false;
  bool filtroVegano = false;
  bool filtroVegetariano = false;
  bool filtroSinTacc = false;
  bool filtroLibros = false;
  bool filtroTranquilo = false;
  bool filtroAireAcondicionado = false;
  bool filtroAireLibre = false;
  bool filtroEstacionamiento = false;
  bool filtroAccesible = false;
  bool filtroCambiador = false;
  bool filtroAlcohol = false;
  bool filtroPasteleria = false;

  String busqueda = '';

  @override
  void initState() {
    super.initState();
    cafesFuture = ApiService.obtenerCafes();
  }
  int get filtrosActivos {
    int total = 0;

    if (filtroWifi) total++;
    if (filtroEnchufes) total++;
    if (filtroEspecialidad) total++;
    if (filtroLaptop) total++;

    if (filtroMascotas) total++;
    if (filtroBrunch) total++;
    if (filtroDesayuno) total++;
    if (filtroVegano) total++;
    if (filtroVegetariano) total++;
    if (filtroSinTacc) total++;

    if (filtroLibros) total++;
    if (filtroTranquilo) total++;

    if (filtroAireAcondicionado) total++;
    if (filtroAireLibre) total++;
    if (filtroEstacionamiento) total++;
    if (filtroAccesible) total++;
    if (filtroCambiador) total++;

    if (filtroPasteleria) total++;
    if (filtroAlcohol) total++;

    return total;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cafeterías'),
      ),
      body: FutureBuilder<List<Cafe>>(
        future: cafesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
              ),
            );
          }

          final cafes = snapshot.data ?? [];

          final cafesFiltrados = cafes.where((cafe) {
            if (!cafe.nombre
                .toLowerCase()
                .contains(busqueda.toLowerCase())) {
              return false;
            }

            if (filtroWifi && !cafe.tieneWifi) {
              return false;
            }

            if (filtroEnchufes && !cafe.enchufes) {
              return false;
            }

            if (filtroEspecialidad && !cafe.cafeEspecialidad) {
              return false;
            }

            if (filtroLaptop && !cafe.laptopFriendly) {
              return false;
            }
            if (filtroMascotas && !cafe.petFriendly) {
          return false;
        }

        if (filtroBrunch && !cafe.brunch) {
          return false;
        }

        if (filtroDesayuno && !cafe.desayuno) {
          return false;
        }

        if (filtroVegano && !cafe.veganFriendly) {
          return false;
        }

        if (filtroVegetariano && !cafe.vegetariano) {
          return false;
        }

        if (filtroSinTacc && !cafe.sinTacc) {
          return false;
        }

        if (filtroLibros && !cafe.librosOJuegos) {
          return false;
        }

        if (filtroTranquilo && !cafe.espacioTranquilo) {
          return false;
        }

        if (filtroAireAcondicionado &&
            !cafe.aireAcondicionado) {
          return false;
        }

        if (filtroAireLibre &&
            !cafe.mesasAlAireLibre) {
          return false;
        }

        if (filtroEstacionamiento &&
            !cafe.estacionamiento) {
          return false;
        }

        if (filtroAccesible &&
            !cafe.accesible) {
          return false;
        }

        if (filtroCambiador &&
            !cafe.cambiadorBebes) {
          return false;
        }
        if (filtroAlcohol &&
            !cafe.alcohol) {
          return false;
        }

        if (filtroPasteleria &&
            !cafe.pasteleriaArtesanal) {
          return false;
        }

            return true;
          }).toList();

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Buscar cafetería...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        busqueda = value;
                      });
                    },
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                  ),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilterChip(
                        label: const Text('📶 Wifi'),
                        selected: filtroWifi,
                        onSelected: (value) {
                          setState(() {
                            filtroWifi = value;
                          });
                        },
                      ),

                      FilterChip(
                        label: const Text('🔌 Enchufes'),
                        selected: filtroEnchufes,
                        onSelected: (value) {
                          setState(() {
                            filtroEnchufes = value;
                          });
                        },
                      ),

                      FilterChip(
                        label: const Text('☕ Especialidad'),
                        selected: filtroEspecialidad,
                        onSelected: (value) {
                          setState(() {
                            filtroEspecialidad = value;
                          });
                        },
                      ),

                      FilterChip(
                        label: const Text('💻 Trabajar'),
                        selected: filtroLaptop,
                        onSelected: (value) {
                          setState(() {
                            filtroLaptop = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.tune),
                      label: Text(
                        filtrosActivos == 0
                            ? 'Más filtros'
                            : 'Más filtros ($filtrosActivos)',
                      ),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (context) {
                            return StatefulBuilder(
                              builder: (context, setModalState) {
                                return SizedBox(
                                  height: MediaQuery.of(context).size.height * 0.65,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                  child: SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Center(
                                          child: Container(
                                            width: 40,
                                            height: 4,
                                            margin: const EdgeInsets.only(bottom: 16),
                                            decoration: BoxDecoration(
                                              color: Colors.grey,
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                          ),
                                        ),

                                        const SizedBox(height: 8),
                                        const Text(
                                          'Más filtros',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),

                                        const SizedBox(height: 16),

                                        const Text(
                                          'Principales',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),

                                        const SizedBox(height: 8),

                                        Wrap(
                                          spacing: 8,
                                          runSpacing: 8,
                                          children: [

                                            FilterChip(
                                              label: const Text('📶 Wifi'),
                                              selected: filtroWifi,
                                              onSelected: (value) {
                                                setState(() {
                                                  filtroWifi = value;
                                                });
                                                setModalState(() {});
                                              },
                                            ),

                                            FilterChip(
                                              label: const Text('🔌 Enchufes'),
                                              selected: filtroEnchufes,
                                              onSelected: (value) {
                                                setState(() {
                                                  filtroEnchufes = value;
                                                });
                                                setModalState(() {});
                                              },
                                            ),

                                            FilterChip(
                                              label: const Text('☕ Especialidad'),
                                              selected: filtroEspecialidad,
                                              onSelected: (value) {
                                                setState(() {
                                                  filtroEspecialidad = value;
                                                });
                                                setModalState(() {});
                                              },
                                            ),

                                            FilterChip(
                                              label: const Text('💻 Trabajar'),
                                              selected: filtroLaptop,
                                              onSelected: (value) {
                                                setState(() {
                                                  filtroLaptop = value;
                                                });
                                                setModalState(() {});
                                              },
                                            ),
                                          ],
                                        ),

                                        const SizedBox(height: 24),

                                        const Text(
                                          'Experiencia',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),

                                        const SizedBox(height: 8),

                                        Wrap(
                                          spacing: 8,
                                          runSpacing: 8,
                                          children: [

                                            FilterChip(
                                              label: const Text('🐶 Mascotas'),
                                              selected: filtroMascotas,
                                              onSelected: (value) {
                                                setState(() {
                                                  filtroMascotas = value;
                                                });
                                                setModalState(() {});
                                              },
                                            ),

                                            FilterChip(
                                              label: const Text('📚 Libros/Juegos'),
                                              selected: filtroLibros,
                                              onSelected: (value) {
                                                setState(() {
                                                  filtroLibros = value;
                                                });
                                                setModalState(() {});
                                              },
                                            ),

                                            FilterChip(
                                              label: const Text('🤫 Tranquilo'),
                                              selected: filtroTranquilo,
                                              onSelected: (value) {
                                                setState(() {
                                                  filtroTranquilo = value;
                                                });
                                                setModalState(() {});
                                              },
                                            ),

                                            ],
                                            ),

                                            const SizedBox(height: 24),


                                        const Text(
                                          'Comida y bebida',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),

                                        const SizedBox(height: 8),

                                        Wrap(
                                          spacing: 8,
                                          runSpacing: 8,
                                          children: [

                                            FilterChip(
                                              label: const Text('🍳 Brunch'),
                                              selected: filtroBrunch,
                                              onSelected: (value) {
                                                setState(() {
                                                  filtroBrunch = value;
                                                });
                                                setModalState(() {});
                                              },
                                            ),

                                            FilterChip(
                                              label: const Text('🥐 Desayuno'),
                                              selected: filtroDesayuno,
                                              onSelected: (value) {
                                                setState(() {
                                                  filtroDesayuno = value;
                                                });
                                                setModalState(() {});
                                              },
                                            ),

                                            FilterChip(
                                              label: const Text('🌱 Vegano'),
                                              selected: filtroVegano,
                                              onSelected: (value) {
                                                setState(() {
                                                  filtroVegano = value;
                                                });
                                                setModalState(() {});
                                              },
                                            ),

                                            FilterChip(
                                              label: const Text('🥗 Vegetariano'),
                                              selected: filtroVegetariano,
                                              onSelected: (value) {
                                                setState(() {
                                                  filtroVegetariano = value;
                                                });
                                                setModalState(() {});
                                              },
                                            ),

                                            FilterChip(
                                              label: const Text('🌾 Sin TACC'),
                                              selected: filtroSinTacc,
                                              onSelected: (value) {
                                                setState(() {
                                                  filtroSinTacc = value;
                                                });
                                                setModalState(() {});
                                              },
                                            ),

                                          ],
                                        ),

                        const SizedBox(height: 24),

                        const Text(
                          'Servicios',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [

                            FilterChip(
                              label: const Text('❄️ Aire acondicionado'),
                              selected: filtroAireAcondicionado,
                              onSelected: (value) {
                                setState(() {
                                  filtroAireAcondicionado = value;
                                });
                                setModalState(() {});
                              },
                            ),

                            FilterChip(
                              label: const Text('☀️ Aire libre'),
                              selected: filtroAireLibre,
                              onSelected: (value) {
                                setState(() {
                                  filtroAireLibre = value;
                                });
                                setModalState(() {});
                              },
                            ),

                            FilterChip(
                              label: const Text('🚗 Estacionamiento'),
                              selected: filtroEstacionamiento,
                              onSelected: (value) {
                                setState(() {
                                  filtroEstacionamiento = value;
                                });
                                setModalState(() {});
                              },
                            ),

                            FilterChip(
                              label: const Text('♿ Accesible'),
                              selected: filtroAccesible,
                              onSelected: (value) {
                                setState(() {
                                  filtroAccesible = value;
                                });
                                setModalState(() {});
                              },
                            ),

                            FilterChip(
                              label: const Text('👶 Cambiador'),
                              selected: filtroCambiador,
                              onSelected: (value) {
                                setState(() {
                                  filtroCambiador = value;
                                });
                                setModalState(() {});
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        const Text(
                          'Cafetería',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [

                            FilterChip(
                              label: const Text('🍰 Pastelería artesanal'),
                              selected: filtroPasteleria,
                              onSelected: (value) {
                                setState(() {
                                  filtroPasteleria = value;
                                });
                                setModalState(() {});
                              },
                            ),

                            FilterChip(
                              label: const Text('🍺 Alcohol'),
                              selected: filtroAlcohol,
                              onSelected: (value) {
                                setState(() {
                                  filtroAlcohol = value;
                                });
                                setModalState(() {});
                              },
                            ),
                          ],
                          ),

                          const SizedBox(height: 24),

                          Center(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.clear),
                              label: const Text('Limpiar filtros'),
                              onPressed: () {
                                setState(() {
                                  filtroWifi = false;
                                  filtroEnchufes = false;
                                  filtroEspecialidad = false;
                                  filtroLaptop = false;

                                  filtroMascotas = false;
                                  filtroBrunch = false;
                                  filtroDesayuno = false;
                                  filtroVegano = false;
                                  filtroVegetariano = false;
                                  filtroSinTacc = false;

                                  filtroLibros = false;
                                  filtroTranquilo = false;

                                  filtroAireAcondicionado = false;
                                  filtroAireLibre = false;
                                  filtroEstacionamiento = false;
                                  filtroAccesible = false;
                                  filtroCambiador = false;

                                  filtroPasteleria = false;
                                  filtroAlcohol = false;
                                });

                                setModalState(() {});
                              },
                            ),
                          ),

                          const SizedBox(height: 24),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.map),
                      label: const Text('Ver mapa'),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CafesMapScreen(
                              cafes: cafesFiltrados,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${cafesFiltrados.length} cafeterías encontradas',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),


                Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cafesFiltrados.length,
                  itemBuilder: (context, index) {
                    final cafe = cafesFiltrados[index];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        onTap: () {
                            print(cafe.tags);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CafeDetailScreen(
                                nombre: cafe.nombre,
                                zona: cafe.zona,
                                rating: cafe.rating,
                                foto: cafe.foto,
                                foto2: cafe.foto2,
                                foto3: cafe.foto3,
                                direccion: cafe.direccion,
                                latitude: cafe.latitude,
                                longitude: cafe.longitude,
                                tieneWifi: cafe.tieneWifi,
                                petFriendly: cafe.petFriendly,
                                veganFriendly: cafe.veganFriendly,
                                tags: cafe.tags,
                                enchufes: cafe.enchufes,
                                cafeEspecialidad: cafe.cafeEspecialidad,
                                brunch: cafe.brunch,
                                laptopFriendly: cafe.laptopFriendly,
                                espacioTranquilo: cafe.espacioTranquilo,
                              ),
                            ),
                          );
                        },
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            cafe.foto,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        ),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              cafe.nombre,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            if (AppState.quieroIr.any(
                              (c) => c.nombre == cafe.nombre,
                            ))
                              const Padding(
                                padding: EdgeInsets.only(top: 4),
                                child: Text(
                                  '☕ Quiero ir',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.brown,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),

                            if (AppState.quieroVolver.any(
                              (c) => c.nombre == cafe.nombre,
                            ))
                              const Padding(
                                padding: EdgeInsets.only(top: 4),
                                child: Text(
                                  '❤️ Quiero volver',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.red,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),

                            if (AppState.yaFui.any(
                              (c) => c.nombre == cafe.nombre,
                            ))
                              const Padding(
                                padding: EdgeInsets.only(top: 4),
                                child: Text(
                                  '✔️ Ya fui',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.green,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (cafe.tags.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Text(
                                  '🏷️ ${cafe.tags.first}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),

                            Text(
                              cafe.zona,
                            ),
                          ],
                        ),
                        trailing: Text(
                          '⭐ ${cafe.rating}',
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}