  import 'package:flutter/material.dart';
  import 'package:geolocator/geolocator.dart';
  import 'cafe_detail_screen.dart';
  import '../models/cafe.dart';
  import '../services/api_service.dart';
  import 'cafes_map_screen.dart';
  import '../widgets/cafe_card.dart';
  import '../widgets/animated_press.dart';
  import '../widgets/animated_list_item.dart';
  import '../widgets/cafe_card_skeleton.dart';

  class CafesScreen extends StatefulWidget {
    const CafesScreen({super.key});

    @override
    State<CafesScreen> createState() => _CafesScreenState();
  }

  class _CafesScreenState extends State<CafesScreen> {
    late Future<List<Cafe>> cafesFuture;

    // Comida y bebida
    bool filtroEspecialidad = false;
    bool filtroBrunch = false;
    bool filtroDesayuno = false;
    bool filtroPasteleria = false;
    bool filtroVegano = false;
    bool filtroVegetariano = false;
    bool filtroSinTacc = false;
    bool filtroSaludable = false;
    bool filtroSinAzucar = false;
    bool filtroLechesVegetales = false;

    // Espacios y lugares diferentes
    bool filtroJardin = false;
    bool filtroVistaAgua = false;
    bool filtroVistaMontanas = false;
    bool filtroNaturaleza = false;
    bool filtroRooftop = false;
    bool filtroVentanales = false;
    bool filtroCasaAntigua = false;
    bool filtroEdificioHistorico = false;
    bool filtroLibreria = false;
    bool filtroEspacioCultural = false;
    bool filtroLibros = false;

    // Servicios
    bool filtroMascotas = false;
    bool filtroKidsFriendly = false;
    bool filtroWifi = false;
    bool filtroEnchufes = false;
    bool filtroAireAcondicionado = false;
    bool filtroAireLibre = false;
    bool filtroEstacionamiento = false;
    bool filtroAccesible = false;
    bool filtroCambiador = false;

    final TextEditingController _searchController =
        TextEditingController();

    String busqueda = '';

    @override
    void initState() {
      super.initState();
      cafesFuture = _cargarCafesConUbicacion();
    }

    Future<List<Cafe>> _cargarCafesConUbicacion({
      bool forzarActualizacion = false,
    }) async {
      try {
        final servicioHabilitado =
            await Geolocator.isLocationServiceEnabled();

        if (!servicioHabilitado) {
          return ApiService.obtenerCafes(
            forzarActualizacion: forzarActualizacion,
          );
        }

        final permiso =
            await Geolocator.checkPermission();

        if (permiso == LocationPermission.denied ||
            permiso == LocationPermission.deniedForever) {
          return ApiService.obtenerCafes(
            forzarActualizacion: forzarActualizacion,
          );
        }

        final posicion =
            await Geolocator.getCurrentPosition();

        return ApiService.obtenerCafes(
          forzarActualizacion: forzarActualizacion,
          latitude: posicion.latitude,
          longitude: posicion.longitude,
        );
      } catch (_) {
        return ApiService.obtenerCafes(
          forzarActualizacion: forzarActualizacion,
        );
      }
    }

    int get filtrosActivos {
      int total = 0;

      // Comida y bebida
      if (filtroEspecialidad) total++;
      if (filtroBrunch) total++;
      if (filtroDesayuno) total++;
      if (filtroPasteleria) total++;
      if (filtroVegano) total++;
      if (filtroVegetariano) total++;
      if (filtroSinTacc) total++;
      if (filtroSaludable) total++;
      if (filtroSinAzucar) total++;
      if (filtroLechesVegetales) total++;

      // Espacio y entorno
      if (filtroJardin) total++;
      if (filtroVistaAgua) total++;
      if (filtroVistaMontanas) total++;
      if (filtroNaturaleza) total++;
      if (filtroRooftop) total++;
      if (filtroVentanales) total++;
      if (filtroCasaAntigua) total++;
      if (filtroEdificioHistorico) total++;
      if (filtroLibreria) total++;
      if (filtroEspacioCultural) total++;

      // Servicios y comodidades
      if (filtroMascotas) total++;
      if (filtroKidsFriendly) total++;
      if (filtroWifi) total++;
      if (filtroEnchufes) total++;
      if (filtroAireAcondicionado) total++;
      if (filtroAireLibre) total++;
      if (filtroEstacionamiento) total++;
      if (filtroAccesible) total++;
      if (filtroCambiador) total++;
      if (filtroLibros) total++;

      return total;
    }

    Future<void> _recargarCafes() async {
      final nuevoFuture = _cargarCafesConUbicacion(
        forzarActualizacion: true,
      );

      setState(() {
        cafesFuture = nuevoFuture;
      });

      await nuevoFuture;
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
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 4,
              itemBuilder: (context, index) {
                return const CafeCardSkeleton();
              },
            );
          }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.cloud_off_outlined,
                        size: 42,
                        color: Colors.black45,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'No pudimos cargar las cafeterías.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Revisá tu conexión e intentá nuevamente.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            cafesFuture =
                                _cargarCafesConUbicacion(
                              forzarActualizacion: true,
                            );
                          });
                        },
                        icon: const Icon(
                          Icons.refresh_rounded,
                        ),
                        label: const Text(
                          'Reintentar',
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            final cafes = snapshot.data ?? [];

            final cafesFiltrados = cafes.where((cafe) {
              final textoBusqueda = busqueda.toLowerCase();

              if (!cafe.nombre.toLowerCase().contains(textoBusqueda) &&
                  !cafe.zona.toLowerCase().contains(textoBusqueda)) {
                return false;
              }

              // Comida y bebida
          if (filtroEspecialidad && !cafe.cafeEspecialidad) {
            return false;
          }

          if (filtroBrunch && !cafe.brunch) {
            return false;
          }

          if (filtroDesayuno && !cafe.desayuno) {
            return false;
          }

          if (filtroPasteleria && !cafe.pasteleriaArtesanal) {
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

          if (filtroSaludable && !cafe.opcionesSaludables) {
            return false;
          }

          if (filtroSinAzucar && !cafe.sinAzucar) {
            return false;
          }

          if (filtroLechesVegetales && !cafe.lechesVegetales) {
            return false;
          }

          // Espacio y entorno
          if (filtroJardin && !cafe.jardin) {
            return false;
          }

          if (filtroVistaAgua && !cafe.vistaAgua) {
            return false;
          }

          if (filtroVistaMontanas && !cafe.vistaMontanas) {
            return false;
          }

          if (filtroNaturaleza && !cafe.rodeadoNaturaleza) {
            return false;
          }

          if (filtroRooftop && !cafe.terrazaRooftop) {
            return false;
          }

          if (filtroVentanales && !cafe.ventanalesGrandes) {
            return false;
          }

          if (filtroCasaAntigua && !cafe.casaAntigua) {
            return false;
          }

          if (filtroEdificioHistorico && !cafe.edificioHistorico) {
            return false;
          }

          if (filtroLibreria && !cafe.dentroLibreria) {
            return false;
          }

          if (filtroEspacioCultural && !cafe.espacioCultural) {
            return false;
          }

          // Servicios y comodidades
          if (filtroMascotas && !cafe.petFriendly) {
            return false;
          }

          if (filtroKidsFriendly && !cafe.kidsFriendly) {
            return false;
          }

          if (filtroWifi && !cafe.tieneWifi) {
            return false;
          }

          if (filtroEnchufes && !cafe.enchufes) {
            return false;
          }

          if (filtroAireAcondicionado && !cafe.aireAcondicionado) {
            return false;
          }

          if (filtroAireLibre && !cafe.mesasAlAireLibre) {
            return false;
          }

          if (filtroEstacionamiento && !cafe.estacionamiento) {
            return false;
          }

          if (filtroAccesible && !cafe.accesible) {
            return false;
          }

          if (filtroCambiador && !cafe.cambiadorBebes) {
            return false;
          }

          if (filtroLibros && !cafe.librosOJuegos) {
            return false;
          }

              return true;
            }).toList();

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      16,
                      12,
                      16,
                      8,
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Buscar cafetería...',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 15,
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: Colors.grey.shade600,
                          size: 22,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 1.5,
                          ),
                        ),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 13,
                        ),
                        suffixIcon: busqueda.isEmpty
                            ? null
                            : IconButton(
                                icon: const Icon(Icons.close),
                                splashRadius: 20,
                                onPressed: () {
                                  _searchController.clear();

                                  setState(() {
                                    busqueda = '';
                                  });
                                },
                              ),
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
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        FilterChip(
                          label: const Text('☕ Especialidad'),
                          selected: filtroEspecialidad,
                          visualDensity: const VisualDensity(
                            horizontal: -2,
                            vertical: -2,
                          ),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          onSelected: (value) {
                            setState(() {
                              filtroEspecialidad = value;
                            });
                          },
                        ),

                        FilterChip(
                          label: const Text('🌿 Jardín'),
                          selected: filtroJardin,
                          visualDensity: const VisualDensity(
                            horizontal: -2,
                            vertical: -2,
                          ),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          onSelected: (value) {
                            setState(() {
                              filtroJardin = value;
                            });
                          },
                        ),

                        FilterChip(
                          label: const Text('🥞 Brunch'),
                          selected: filtroBrunch,
                          visualDensity: const VisualDensity(
                            horizontal: -2,
                            vertical: -2,
                          ),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          onSelected: (value) {
                            setState(() {
                              filtroBrunch = value;
                            });
                          },
                        ),

                        FilterChip(
                          label: const Text('🐶 Pet Friendly'),
                          selected: filtroMascotas,
                          visualDensity: const VisualDensity(
                            horizontal: -2,
                            vertical: -2,
                          ),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          onSelected: (value) {
                            setState(() {
                              filtroMascotas = value;
                            });
                          },
                        ),

                        FilterChip(
                          label: const Text('📶 Wifi'),
                          selected: filtroWifi,
                          visualDensity: const VisualDensity(
                            horizontal: -2,
                            vertical: -2,
                          ),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          onSelected: (value) {
                            setState(() {
                              filtroWifi = value;
                            });
                          },
                        ),
                                            ],
                    ),
                  ),

                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _recargarCafes,
                      child: CustomScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        slivers: [
                          SliverToBoxAdapter(
                            child: Column(
                              children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                16,
                                12,
                                16,
                                0,
                              ),
                              child: Row(
                      children: [
                        Expanded(
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
                                          Text(
                                            'Filtros',
                                            style: TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.w700,
                                              color: Theme.of(context).colorScheme.primary,
                                            ),
                                          ),

                                          const SizedBox(height: 16),

                                          if (filtrosActivos > 0)
                                            Container(
                                              width: double.infinity,
                                              margin: const EdgeInsets.only(bottom: 20),
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 14,
                                                vertical: 12,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary
                                                    .withValues(alpha: 0.08),
                                                borderRadius: BorderRadius.circular(14),
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.tune,
                                                    size: 20,
                                                    color: Theme.of(context).colorScheme.primary,
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Expanded(
                                                    child: Text(
                                                      '$filtrosActivos filtro${filtrosActivos == 1 ? '' : 's'} aplicado${filtrosActivos == 1 ? '' : 's'}',
                                                      style: TextStyle(
                                                        color: Theme.of(context).colorScheme.primary,
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),

                                          Row(
                                            children: [
                                              Icon(
                                                Icons.restaurant_menu,
                                                size: 20,
                                                color: Theme.of(context).colorScheme.primary,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                '☕ Para comer y tomar',
                                                style: TextStyle(
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.w700,
                                                  color: Theme.of(context).colorScheme.primary,
                                                ),
                                              ),
                                            ],
                                          ),

                                          const SizedBox(height: 8),

                                          Wrap(
                                            spacing: 8,
                                            runSpacing: 8,
                                            children: [
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
                                                label: const Text('🥐 Pastelería artesanal'),
                                                selected: filtroPasteleria,
                                                onSelected: (value) {
                                                  setState(() {
                                                    filtroPasteleria = value;
                                                  });
                                                  setModalState(() {});
                                                },
                                              ),
                                              FilterChip(
                                                label: const Text('🥞 Brunch'),
                                                selected: filtroBrunch,
                                                onSelected: (value) {
                                                  setState(() {
                                                    filtroBrunch = value;
                                                  });
                                                  setModalState(() {});
                                                },
                                              ),
                                              FilterChip(
                                                label: const Text('🍳 Desayuno'),
                                                selected: filtroDesayuno,
                                                onSelected: (value) {
                                                  setState(() {
                                                    filtroDesayuno = value;
                                                  });
                                                  setModalState(() {});
                                                },
                                              ),
                                              FilterChip(
                                                label: const Text('🥑 Saludables'),
                                                selected: filtroSaludable,
                                                onSelected: (value) {
                                                  setState(() {
                                                    filtroSaludable = value;
                                                  });
                                                  setModalState(() {});
                                                },
                                              ),
                                              FilterChip(
                                                label: const Text('🚫🍬 Sin azúcar'),
                                                selected: filtroSinAzucar,
                                                onSelected: (value) {
                                                  setState(() {
                                                    filtroSinAzucar = value;
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
                                              FilterChip(
                                                label: const Text('🥛 Leches vegetales'),
                                                selected: filtroLechesVegetales,
                                                onSelected: (value) {
                                                  setState(() {
                                                    filtroLechesVegetales = value;
                                                  });
                                                  setModalState(() {});
                                                },
                                              ),
                                              FilterChip(
                                                label: const Text('🌱 Veganas'),
                                                selected: filtroVegano,
                                                onSelected: (value) {
                                                  setState(() {
                                                    filtroVegano = value;
                                                  });
                                                  setModalState(() {});
                                                },
                                              ),
                                              FilterChip(
                                                label: const Text('🥕 Vegetarianas'),
                                                selected: filtroVegetariano,
                                                onSelected: (value) {
                                                  setState(() {
                                                    filtroVegetariano = value;
                                                  });
                                                  setModalState(() {});
                                                },
                                              ),
                                            ],
                                          ),

                                          const SizedBox(height: 28),

                                          Row(
                                            children: [
                                              Icon(
                                                Icons.landscape_outlined,
                                                size: 20,
                                                color: Theme.of(context).colorScheme.primary,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                '🌿 Espacio y entorno',
                                                style: TextStyle(
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.w700,
                                                  color: Theme.of(context).colorScheme.primary,
                                                ),
                                              ),
                                            ],
                                          ),

                                          const SizedBox(height: 8),

                                          Wrap(
                                            spacing: 8,
                                            runSpacing: 8,
                                            children: [
                                              FilterChip(
                                                label: const Text('🌿 Con jardín'),
                                                selected: filtroJardin,
                                                onSelected: (value) {
                                                  setState(() {
                                                    filtroJardin = value;
                                                  });
                                                  setModalState(() {});
                                                },
                                              ),
                                              FilterChip(
                                                label: const Text('🌊 Vista al agua'),
                                                selected: filtroVistaAgua,
                                                onSelected: (value) {
                                                  setState(() {
                                                    filtroVistaAgua = value;
                                                  });
                                                  setModalState(() {});
                                                },
                                              ),
                                              FilterChip(
                                                label: const Text('⛰️ Sierras / montañas'),
                                                selected: filtroVistaMontanas,
                                                onSelected: (value) {
                                                  setState(() {
                                                    filtroVistaMontanas = value;
                                                  });
                                                  setModalState(() {});
                                                },
                                              ),
                                              FilterChip(
                                                label: const Text('🌳 Rodeado de naturaleza'),
                                                selected: filtroNaturaleza,
                                                onSelected: (value) {
                                                  setState(() {
                                                    filtroNaturaleza = value;
                                                  });
                                                  setModalState(() {});
                                                },
                                              ),
                                              FilterChip(
                                                label: const Text('🌇 Terraza o rooftop'),
                                                selected: filtroRooftop,
                                                onSelected: (value) {
                                                  setState(() {
                                                    filtroRooftop = value;
                                                  });
                                                  setModalState(() {});
                                                },
                                              ),
                                              FilterChip(
                                                label: const Text('🪟 Grandes ventanales'),
                                                selected: filtroVentanales,
                                                onSelected: (value) {
                                                  setState(() {
                                                    filtroVentanales = value;
                                                  });
                                                  setModalState(() {});
                                                },
                                              ),
                                              FilterChip(
                                                label: const Text('🏡 Casa antigua'),
                                                selected: filtroCasaAntigua,
                                                onSelected: (value) {
                                                  setState(() {
                                                    filtroCasaAntigua = value;
                                                  });
                                                  setModalState(() {});
                                                },
                                              ),
                                              FilterChip(
                                                label: const Text('🏛️ Edificio histórico'),
                                                selected: filtroEdificioHistorico,
                                                onSelected: (value) {
                                                  setState(() {
                                                    filtroEdificioHistorico = value;
                                                  });
                                                  setModalState(() {});
                                                },
                                              ),
                                              FilterChip(
                                                label: const Text('📚 Dentro de una librería'),
                                                selected: filtroLibreria,
                                                onSelected: (value) {
                                                  setState(() {
                                                    filtroLibreria = value;
                                                  });
                                                  setModalState(() {});
                                                },
                                              ),
                                              FilterChip(
                                                label: const Text('🎨 Espacio cultural'),
                                                selected: filtroEspacioCultural,
                                                onSelected: (value) {
                                                  setState(() {
                                                    filtroEspacioCultural = value;
                                                  });
                                                  setModalState(() {});
                                                },
                                              ),
                                            ],
                                          ),

                                          const SizedBox(height: 28),

                                          Row(
                                            children: [
                                              Icon(
                                                Icons.room_preferences_outlined,
                                                size: 20,
                                                color: Theme.of(context).colorScheme.primary,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                '🐶 Servicios y comodidades',
                                                style: TextStyle(
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.w700,
                                                  color: Theme.of(context).colorScheme.primary,
                                                ),
                                              ),
                                            ],
                                          ),

                                          const SizedBox(height: 8),

                                          Wrap(
                                            spacing: 8,
                                            runSpacing: 8,
                                            children: [
                                              FilterChip(
                                                label: const Text('🐶 Pet friendly'),
                                                selected: filtroMascotas,
                                                onSelected: (value) {
                                                  setState(() {
                                                    filtroMascotas = value;
                                                  });
                                                  setModalState(() {});
                                                },
                                              ),
                                              FilterChip(
                                                label: const Text('👶 Kids friendly'),
                                                selected: filtroKidsFriendly,
                                                onSelected: (value) {
                                                  setState(() {
                                                    filtroKidsFriendly = value;
                                                  });
                                                  setModalState(() {});
                                                },
                                              ),
                                              FilterChip(
                                                label: const Text('📶 Wi-Fi'),
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
                                                label: const Text('🌤️ Mesas al aire libre'),
                                                selected: filtroAireLibre,
                                                onSelected: (value) {
                                                  setState(() {
                                                    filtroAireLibre = value;
                                                  });
                                                  setModalState(() {});
                                                },
                                              ),
                                              FilterChip(
                                                label: const Text('🅿️ Estacionamiento'),
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
                                                label: const Text('👶 Cambiador para bebés'),
                                                selected: filtroCambiador,
                                                onSelected: (value) {
                                                  setState(() {
                                                    filtroCambiador = value;
                                                  });
                                                  setModalState(() {});
                                                },
                                              ),
                                              FilterChip(
                                                label: const Text('🎲 Libros o juegos'),
                                                selected: filtroLibros,
                                                onSelected: (value) {
                                                  setState(() {
                                                    filtroLibros = value;
                                                  });
                                                  setModalState(() {});
                                                },
                                              ),
                                            ],
                                          ),

                            const SizedBox(height: 28),

                            Center(
                              child: OutlinedButton.icon(
                                icon: const Icon(Icons.clear),
                                label: const Text('Limpiar filtros'),
                                onPressed: () {
                                  setState(() {
                                    // Comida y bebida
                                    filtroEspecialidad = false;
                                    filtroBrunch = false;
                                    filtroDesayuno = false;
                                    filtroPasteleria = false;
                                    filtroVegano = false;
                                    filtroVegetariano = false;
                                    filtroSinTacc = false;
                                    filtroSaludable = false;
                                    filtroSinAzucar = false;
                                    filtroLechesVegetales = false;

                                    // Espacio y entorno
                                    filtroJardin = false;
                                    filtroVistaAgua = false;
                                    filtroVistaMontanas = false;
                                    filtroNaturaleza = false;
                                    filtroRooftop = false;
                                    filtroVentanales = false;
                                    filtroCasaAntigua = false;
                                    filtroEdificioHistorico = false;
                                    filtroLibreria = false;
                                    filtroEspacioCultural = false;

                                    // Servicios y comodidades
                                    filtroMascotas = false;
                                    filtroKidsFriendly = false;
                                    filtroWifi = false;
                                    filtroEnchufes = false;
                                    filtroAireAcondicionado = false;
                                    filtroAireLibre = false;
                                    filtroEstacionamiento = false;
                                    filtroAccesible = false;
                                    filtroCambiador = false;
                                    filtroLibros = false;
                                  });

                                  setModalState(() {});
                                },
                              ),
                            ),

                            const SizedBox(height: 28),
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

                      const SizedBox(width: 8),

                      Expanded(
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
                    ],
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
                        '${cafesFiltrados.length} cafeterías para descubrir',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),
                ],
              ),
            ),

          if (cafesFiltrados.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'No encontramos cafeterías con esos filtros ☕',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                16,
                0,
                16,
                24,
              ),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final cafe = cafesFiltrados[index];

                    return AnimatedListItem(
                      index: index,
                      child: AnimatedPress(
                        borderRadius:
                            BorderRadius.circular(22),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  CafeDetailScreen(
                                cafeId: cafe.id!,
                              ),
                            ),
                          );
                        },
                        child: CafeCard(
                          cafe: cafe,
                        ),
                      ),
                    );
                  },
                  childCount: cafesFiltrados.length,
                ),
              ),
            ),
        ],
      ),
    ),
  ),
],
);
          },
        ),
      );
    }
  }