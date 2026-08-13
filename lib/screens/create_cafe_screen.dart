import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class CreateCafeScreen extends StatefulWidget {
  const CreateCafeScreen({super.key});

  @override
  State<CreateCafeScreen> createState() =>
      _CreateCafeScreenState();
}

class _CreateCafeScreenState
    extends State<CreateCafeScreen> {
  int pasoActual = 0;

  final nombreController = TextEditingController();
  final direccionController = TextEditingController();
  final localidadController = TextEditingController();
  final instagramController = TextEditingController();
  final googleMapsController = TextEditingController();

  String provinciaSeleccionada = '';

  final ImagePicker imagePicker = ImagePicker();

  XFile? fotoPrincipal;
  XFile? foto2;
  XFile? foto3;

    bool tieneWifi = false;
    bool aireAcondicionado = false;
    bool enchufes = false;
    bool mesasAlAireLibre = false;
    bool estacionamiento = false;
    bool accesible = false;
    bool cambiadorBebes = false;
    bool petFriendly = false;
    bool cafeEspecialidad = false;
    bool brunch = false;
    bool desayuno = false;
    bool alcohol = false;
    bool pasteleriaArtesanal = false;
    bool veganFriendly = false;
    bool vegetariano = false;
    bool sinTacc = false;
    bool librosOJuegos = false;

  final provincias = const [
    'Buenos Aires',
    'CABA',
    'Catamarca',
    'Chaco',
    'Chubut',
    'Córdoba',
    'Corrientes',
    'Entre Ríos',
    'Formosa',
    'Jujuy',
    'La Pampa',
    'La Rioja',
    'Mendoza',
    'Misiones',
    'Neuquén',
    'Río Negro',
    'Salta',
    'San Juan',
    'San Luis',
    'Santa Cruz',
    'Santa Fe',
    'Santiago del Estero',
    'Tierra del Fuego',
    'Tucumán',
  ];

  @override
  void dispose() {
    nombreController.dispose();
    direccionController.dispose();
    localidadController.dispose();
    instagramController.dispose();
    googleMapsController.dispose();

    super.dispose();
  }

    void siguientePaso() {
    if (pasoActual == 0) {
        final nombre = nombreController.text.trim();
        final direccion = direccionController.text.trim();
        final localidad = localidadController.text.trim();

        if (nombre.isEmpty) {
        mostrarError(
            'Ingresá el nombre de la cafetería.',
        );
        return;
        }

        if (direccion.length < 5) {
        mostrarError(
            'Ingresá una dirección válida.',
        );
        return;
        }

        if (!direccion.contains(RegExp(r'\d'))) {
        mostrarError(
            'La dirección debe incluir un número.',
        );
        return;
        }

        if (localidad.isEmpty) {
        mostrarError(
            'Ingresá la localidad.',
        );
        return;
        }

        if (provinciaSeleccionada.isEmpty) {
        mostrarError(
            'Seleccioná una provincia.',
        );
        return;
        }

        if (fotoPrincipal == null) {
        mostrarError(
            'Elegí una foto principal de la cafetería.',
        );
        return;
        }
    }

    if (pasoActual < 2) {
        setState(() {
        pasoActual++;
        });
    }
    }

    Future<XFile?> elegirImagen() async {
        return imagePicker.pickImage(
            source: ImageSource.gallery,
            imageQuality: 85,
            maxWidth: 1600,
        );
        }

        Future<void> seleccionarFotoPrincipal() async {
        final imagen = await elegirImagen();

        if (imagen == null || !mounted) {
            return;
        }

        setState(() {
            fotoPrincipal = imagen;
        });
        }

        Future<void> seleccionarFoto2() async {
        final imagen = await elegirImagen();

        if (imagen == null || !mounted) {
            return;
        }

        setState(() {
            foto2 = imagen;
        });
        }

        Future<void> seleccionarFoto3() async {
        final imagen = await elegirImagen();

        if (imagen == null || !mounted) {
            return;
        }

        setState(() {
            foto3 = imagen;
        });
        }

    void mostrarError(String mensaje) {
        ScaffoldMessenger.of(context)
            .hideCurrentSnackBar();

        ScaffoldMessenger.of(context)
            .showSnackBar(
            SnackBar(
            content: Text(mensaje),
            ),
        );
        }

  void pasoAnterior() {
    if (pasoActual > 0) {
      setState(() {
        pasoActual--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Sumar cafetería',
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                24,
                18,
                24,
                8,
              ),
              child: _IndicadorPasos(
                pasoActual: pasoActual,
              ),
            ),

            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(
                  milliseconds: 220,
                ),
                child: _contenidoPaso(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _contenidoPaso() {
    switch (pasoActual) {
        case 0:
        return _PasoDatos(
            key: const ValueKey('datos'),
            nombreController: nombreController,
            direccionController: direccionController,
            localidadController: localidadController,
            instagramController: instagramController,
            googleMapsController: googleMapsController,
            provinciaSeleccionada: provinciaSeleccionada,
            provincias: provincias,
            onProvinciaChanged: (value) {
            setState(() {
                provinciaSeleccionada = value ?? '';
            });
            },
            fotoPrincipal: fotoPrincipal,
            foto2: foto2,
            foto3: foto3,
            onSeleccionarFotoPrincipal: seleccionarFotoPrincipal,
            onSeleccionarFoto2: seleccionarFoto2,
            onSeleccionarFoto3: seleccionarFoto3,
            onContinuar: siguientePaso,
        );

        case 1:
        return _PasoCaracteristicas(
            key: const ValueKey('caracteristicas'),

            tieneWifi: tieneWifi,
            aireAcondicionado: aireAcondicionado,
            enchufes: enchufes,
            mesasAlAireLibre: mesasAlAireLibre,
            estacionamiento: estacionamiento,
            accesible: accesible,
            cambiadorBebes: cambiadorBebes,
            petFriendly: petFriendly,
            cafeEspecialidad: cafeEspecialidad,
            brunch: brunch,
            desayuno: desayuno,
            alcohol: alcohol,
            pasteleriaArtesanal: pasteleriaArtesanal,
            veganFriendly: veganFriendly,
            vegetariano: vegetariano,
            sinTacc: sinTacc,
            librosOJuegos: librosOJuegos,

            onTieneWifiChanged: (value) {
            setState(() {
                tieneWifi = value;
            });
            },
            onAireAcondicionadoChanged: (value) {
            setState(() {
                aireAcondicionado = value;
            });
            },
            onEnchufesChanged: (value) {
            setState(() {
                enchufes = value;
            });
            },
            onMesasAlAireLibreChanged: (value) {
            setState(() {
                mesasAlAireLibre = value;
            });
            },
            onEstacionamientoChanged: (value) {
            setState(() {
                estacionamiento = value;
            });
            },
            onAccesibleChanged: (value) {
            setState(() {
                accesible = value;
            });
            },
            onCambiadorBebesChanged: (value) {
            setState(() {
                cambiadorBebes = value;
            });
            },
            onPetFriendlyChanged: (value) {
            setState(() {
                petFriendly = value;
            });
            },
            onCafeEspecialidadChanged: (value) {
            setState(() {
                cafeEspecialidad = value;
            });
            },
            onBrunchChanged: (value) {
            setState(() {
                brunch = value;
            });
            },
            onDesayunoChanged: (value) {
            setState(() {
                desayuno = value;
            });
            },
            onAlcoholChanged: (value) {
            setState(() {
                alcohol = value;
            });
            },
            onPasteleriaArtesanalChanged: (value) {
            setState(() {
                pasteleriaArtesanal = value;
            });
            },
            onVeganFriendlyChanged: (value) {
            setState(() {
                veganFriendly = value;
            });
            },
            onVegetarianoChanged: (value) {
            setState(() {
                vegetariano = value;
            });
            },
            onSinTaccChanged: (value) {
            setState(() {
                sinTacc = value;
            });
            },
            onLibrosOJuegosChanged: (value) {
            setState(() {
                librosOJuegos = value;
            });
            },

            onVolver: pasoAnterior,
            onContinuar: siguientePaso,
        );

        default:
        return _PasoRevision(
            key: const ValueKey('revision'),
            nombre: nombreController.text.trim(),
            direccion: direccionController.text.trim(),
            localidad: localidadController.text.trim(),
            provincia: provinciaSeleccionada,
            instagram: instagramController.text.trim(),
            googleMaps: googleMapsController.text.trim(),
            fotoPrincipal: fotoPrincipal,
            foto2: foto2,
            foto3: foto3,

            tieneWifi: tieneWifi,
            aireAcondicionado: aireAcondicionado,
            enchufes: enchufes,
            mesasAlAireLibre: mesasAlAireLibre,
            estacionamiento: estacionamiento,
            accesible: accesible,
            cambiadorBebes: cambiadorBebes,
            petFriendly: petFriendly,
            cafeEspecialidad: cafeEspecialidad,
            brunch: brunch,
            desayuno: desayuno,
            alcohol: alcohol,
            pasteleriaArtesanal: pasteleriaArtesanal,
            veganFriendly: veganFriendly,
            vegetariano: vegetariano,
            sinTacc: sinTacc,
            librosOJuegos: librosOJuegos,

            onVolver: pasoAnterior,
        );
    }
  }
}

class _IndicadorPasos extends StatelessWidget {
  final int pasoActual;

  const _IndicadorPasos({
    required this.pasoActual,
  });

  @override
  Widget build(BuildContext context) {
    final labels = [
      'Tu cafetería',
      'Qué ofrece',
      'Revisar',
    ];

    return Row(
      children: List.generate(
        labels.length,
        (index) {
          final activo =
              index <= pasoActual;

          return Expanded(
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: activo
                        ? const Color(0xFF1E3A8A)
                        : const Color(0xFFE5E7EB),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: activo
                          ? Colors.white
                          : const Color(0xFF6B7280),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

                if (index < labels.length - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: index < pasoActual
                          ? const Color(0xFF1E3A8A)
                          : const Color(0xFFE5E7EB),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PasoDatos extends StatelessWidget {
  final TextEditingController nombreController;
  final TextEditingController direccionController;
  final TextEditingController localidadController;
  final TextEditingController instagramController;
  final TextEditingController googleMapsController;

  final String provinciaSeleccionada;
  final List<String> provincias;

  final ValueChanged<String?> onProvinciaChanged;
  final VoidCallback onContinuar;
  final XFile? fotoPrincipal;
  final XFile? foto2;
  final XFile? foto3;

  final VoidCallback onSeleccionarFotoPrincipal;
  final VoidCallback onSeleccionarFoto2;
  final VoidCallback onSeleccionarFoto3;

  const _PasoDatos({
    super.key,
    required this.nombreController,
    required this.direccionController,
    required this.localidadController,
    required this.instagramController,
    required this.googleMapsController,
    required this.provinciaSeleccionada,
    required this.provincias,
    required this.onProvinciaChanged,
    required this.onContinuar,
    required this.fotoPrincipal,
    required this.foto2,
    required this.foto3,
    required this.onSeleccionarFotoPrincipal,
    required this.onSeleccionarFoto2,
    required this.onSeleccionarFoto3,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        24,
        20,
        24,
        32,
      ),
      children: [
        const Text(
          'Contanos sobre tu cafetería',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Color(0xFF111827),
          ),
        ),

        const SizedBox(height: 8),

        const Text(
          'Empecemos por los datos básicos.',
          style: TextStyle(
            fontSize: 15,
            color: Colors.black54,
          ),
        ),

        const SizedBox(height: 24),

        TextField(
          controller: nombreController,
          textCapitalization:
              TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Nombre de la cafetería *',
          ),
        ),

        const SizedBox(height: 14),

        TextField(
          controller: direccionController,
          textCapitalization:
              TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Dirección *',
            hintText: 'Ej: Mitre 123',
          ),
        ),

        const SizedBox(height: 14),

        TextField(
          controller: localidadController,
          textCapitalization:
              TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Localidad *',
          ),
        ),

        const SizedBox(height: 14),

        DropdownButtonFormField<String>(
          initialValue:
              provinciaSeleccionada.isEmpty
                  ? null
                  : provinciaSeleccionada,
          decoration: const InputDecoration(
            labelText: 'Provincia *',
          ),
          items: provincias
              .map(
                (provincia) =>
                    DropdownMenuItem(
                  value: provincia,
                  child: Text(provincia),
                ),
              )
              .toList(),
          onChanged: onProvinciaChanged,
        ),

        const SizedBox(height: 14),

        TextField(
          controller: instagramController,
          decoration: const InputDecoration(
            labelText: 'Instagram',
            hintText: '@tu.cafeteria',
          ),
        ),

        const SizedBox(height: 14),

        TextField(
          controller: googleMapsController,
          keyboardType: TextInputType.url,
          decoration: const InputDecoration(
            labelText: 'Link de Google Maps',
          ),
        ),

        const SizedBox(height: 22),

            const Text(
                'Fotos de la cafetería',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                ),
                ),

                const SizedBox(height: 5),

                const Text(
                'La primera foto es obligatoria. Podés sumar hasta 3.',
                style: TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                ),
                ),

                const SizedBox(height: 12),

                _FotoSelector(
                foto: fotoPrincipal,
                titulo: 'Foto principal *',
                onTap: onSeleccionarFotoPrincipal,
                ),

                const SizedBox(height: 12),

                Row(
                children: [
                    Expanded(
                    child: _FotoSelector(
                        foto: foto2,
                        titulo: 'Foto 2',
                        onTap: onSeleccionarFoto2,
                        compacto: true,
                    ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                    child: _FotoSelector(
                        foto: foto3,
                        titulo: 'Foto 3',
                        onTap: onSeleccionarFoto3,
                        compacto: true,
                    ),
                    ),
                ],
                ),

        const SizedBox(height: 28),

        ElevatedButton(
          onPressed: onContinuar,
          child: const Text(
            'Continuar',
          ),
        ),
      ],
    );
  }
}

class _FotoSelector extends StatelessWidget {
  final XFile? foto;
  final String titulo;
  final VoidCallback onTap;
  final bool compacto;

  const _FotoSelector({
    required this.foto,
    required this.titulo,
    required this.onTap,
    this.compacto = false,
  });

  @override
  Widget build(BuildContext context) {
    final altura = compacto ? 130.0 : 190.0;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: altura,
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFFE5E7EB),
          ),
        ),
        child: foto == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 32,
                    color: Color(0xFF1E3A8A),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    titulo,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF172C6D),
                    ),
                  ),

                  if (!compacto) ...[
                    const SizedBox(height: 4),
                    const Text(
                      'JPG o PNG · máximo 4 MB',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ],
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(17),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(
                      File(foto!.path),
                      fit: BoxFit.cover,
                    ),

                    Positioned(
                      right: 8,
                      bottom: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'Cambiar',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _PasoCaracteristicas extends StatelessWidget {
  final bool tieneWifi;
  final bool aireAcondicionado;
  final bool enchufes;
  final bool mesasAlAireLibre;
  final bool estacionamiento;
  final bool accesible;
  final bool cambiadorBebes;
  final bool petFriendly;
  final bool cafeEspecialidad;
  final bool brunch;
  final bool desayuno;
  final bool alcohol;
  final bool pasteleriaArtesanal;
  final bool veganFriendly;
  final bool vegetariano;
  final bool sinTacc;
  final bool librosOJuegos;

  final ValueChanged<bool> onTieneWifiChanged;
  final ValueChanged<bool> onAireAcondicionadoChanged;
  final ValueChanged<bool> onEnchufesChanged;
  final ValueChanged<bool> onMesasAlAireLibreChanged;
  final ValueChanged<bool> onEstacionamientoChanged;
  final ValueChanged<bool> onAccesibleChanged;
  final ValueChanged<bool> onCambiadorBebesChanged;
  final ValueChanged<bool> onPetFriendlyChanged;
  final ValueChanged<bool> onCafeEspecialidadChanged;
  final ValueChanged<bool> onBrunchChanged;
  final ValueChanged<bool> onDesayunoChanged;
  final ValueChanged<bool> onAlcoholChanged;
  final ValueChanged<bool> onPasteleriaArtesanalChanged;
  final ValueChanged<bool> onVeganFriendlyChanged;
  final ValueChanged<bool> onVegetarianoChanged;
  final ValueChanged<bool> onSinTaccChanged;
  final ValueChanged<bool> onLibrosOJuegosChanged;

  final VoidCallback onVolver;
  final VoidCallback onContinuar;

  const _PasoCaracteristicas({
    super.key,
    required this.tieneWifi,
    required this.aireAcondicionado,
    required this.enchufes,
    required this.mesasAlAireLibre,
    required this.estacionamiento,
    required this.accesible,
    required this.cambiadorBebes,
    required this.petFriendly,
    required this.cafeEspecialidad,
    required this.brunch,
    required this.desayuno,
    required this.alcohol,
    required this.pasteleriaArtesanal,
    required this.veganFriendly,
    required this.vegetariano,
    required this.sinTacc,
    required this.librosOJuegos,
    required this.onTieneWifiChanged,
    required this.onAireAcondicionadoChanged,
    required this.onEnchufesChanged,
    required this.onMesasAlAireLibreChanged,
    required this.onEstacionamientoChanged,
    required this.onAccesibleChanged,
    required this.onCambiadorBebesChanged,
    required this.onPetFriendlyChanged,
    required this.onCafeEspecialidadChanged,
    required this.onBrunchChanged,
    required this.onDesayunoChanged,
    required this.onAlcoholChanged,
    required this.onPasteleriaArtesanalChanged,
    required this.onVeganFriendlyChanged,
    required this.onVegetarianoChanged,
    required this.onSinTaccChanged,
    required this.onLibrosOJuegosChanged,
    required this.onVolver,
    required this.onContinuar,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        24,
        20,
        24,
        32,
      ),
      children: [
        const Text(
          '¿Qué ofrece tu cafetería?',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Color(0xFF111827),
          ),
        ),

        const SizedBox(height: 8),

        const Text(
          'Elegí las características que tiene tu cafetería. '
          'Podés cambiarlas después.',
          style: TextStyle(
            fontSize: 15,
            height: 1.4,
            color: Colors.black54,
          ),
        ),

        const SizedBox(height: 24),

        _CaracteristicaTile(
          icon: Icons.wifi_rounded,
          label: 'Wi-Fi disponible',
          value: tieneWifi,
          onChanged: onTieneWifiChanged,
        ),
        _CaracteristicaTile(
          icon: Icons.ac_unit_rounded,
          label: 'Aire acondicionado',
          value: aireAcondicionado,
          onChanged: onAireAcondicionadoChanged,
        ),
        _CaracteristicaTile(
          icon: Icons.power_outlined,
          label: 'Enchufes disponibles',
          value: enchufes,
          onChanged: onEnchufesChanged,
        ),
        _CaracteristicaTile(
          icon: Icons.deck_outlined,
          label: 'Mesas al aire libre',
          value: mesasAlAireLibre,
          onChanged: onMesasAlAireLibreChanged,
        ),
        _CaracteristicaTile(
          icon: Icons.local_parking_outlined,
          label: 'Estacionamiento',
          value: estacionamiento,
          onChanged: onEstacionamientoChanged,
        ),
        _CaracteristicaTile(
          icon: Icons.accessible_rounded,
          label: 'Accesible',
          value: accesible,
          onChanged: onAccesibleChanged,
        ),
        _CaracteristicaTile(
          icon: Icons.baby_changing_station_outlined,
          label: 'Cambiador para bebés',
          value: cambiadorBebes,
          onChanged: onCambiadorBebesChanged,
        ),
        _CaracteristicaTile(
          icon: Icons.pets_outlined,
          label: 'Apto mascotas',
          value: petFriendly,
          onChanged: onPetFriendlyChanged,
        ),
        _CaracteristicaTile(
          icon: Icons.coffee_outlined,
          label: 'Café de especialidad',
          value: cafeEspecialidad,
          onChanged: onCafeEspecialidadChanged,
        ),
        _CaracteristicaTile(
          icon: Icons.brunch_dining_outlined,
          label: 'Brunch',
          value: brunch,
          onChanged: onBrunchChanged,
        ),
        _CaracteristicaTile(
          icon: Icons.free_breakfast_outlined,
          label: 'Desayuno',
          value: desayuno,
          onChanged: onDesayunoChanged,
        ),
        _CaracteristicaTile(
          icon: Icons.local_bar_outlined,
          label: 'Sirve alcohol',
          value: alcohol,
          onChanged: onAlcoholChanged,
        ),
        _CaracteristicaTile(
          icon: Icons.bakery_dining_outlined,
          label: 'Pastelería artesanal',
          value: pasteleriaArtesanal,
          onChanged: onPasteleriaArtesanalChanged,
        ),
        _CaracteristicaTile(
          icon: Icons.eco_outlined,
          label: 'Opciones veganas',
          value: veganFriendly,
          onChanged: onVeganFriendlyChanged,
        ),
        _CaracteristicaTile(
          icon: Icons.grass_outlined,
          label: 'Opciones vegetarianas',
          value: vegetariano,
          onChanged: onVegetarianoChanged,
        ),
        _CaracteristicaTile(
          icon: Icons.no_food_outlined,
          label: 'Opciones sin gluten / Sin TACC',
          value: sinTacc,
          onChanged: onSinTaccChanged,
        ),
        _CaracteristicaTile(
          icon: Icons.menu_book_outlined,
          label: 'Libros o juegos',
          value: librosOJuegos,
          onChanged: onLibrosOJuegosChanged,
        ),

        const SizedBox(height: 24),

        OutlinedButton(
          onPressed: onVolver,
          child: const Text('Volver'),
        ),

        const SizedBox(height: 12),

        ElevatedButton(
          onPressed: onContinuar,
          child: const Text('Continuar'),
        ),
      ],
    );
  }
}

class _CaracteristicaTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _CaracteristicaTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 10,
      ),
      decoration: BoxDecoration(
        color: value
            ? const Color(0xFFEFF6FF)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: value
              ? const Color(0xFFBFDBFE)
              : const Color(0xFFE5E7EB),
        ),
      ),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        activeThumbColor: const Color(0xFF1E3A8A),
        title: Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
          ),
        ),
        secondary: Icon(
          icon,
          color: const Color(0xFF172C6D),
        ),
      ),
    );
  }
}

class _PasoRevision extends StatelessWidget {
  final String nombre;
  final String direccion;
  final String localidad;
  final String provincia;
  final String instagram;
  final String googleMaps;

  final XFile? fotoPrincipal;
  final XFile? foto2;
  final XFile? foto3;

  final bool tieneWifi;
  final bool aireAcondicionado;
  final bool enchufes;
  final bool mesasAlAireLibre;
  final bool estacionamiento;
  final bool accesible;
  final bool cambiadorBebes;
  final bool petFriendly;
  final bool cafeEspecialidad;
  final bool brunch;
  final bool desayuno;
  final bool alcohol;
  final bool pasteleriaArtesanal;
  final bool veganFriendly;
  final bool vegetariano;
  final bool sinTacc;
  final bool librosOJuegos;

  final VoidCallback onVolver;

  const _PasoRevision({
    super.key,
    required this.nombre,
    required this.direccion,
    required this.localidad,
    required this.provincia,
    required this.instagram,
    required this.googleMaps,
    required this.fotoPrincipal,
    required this.foto2,
    required this.foto3,
    required this.tieneWifi,
    required this.aireAcondicionado,
    required this.enchufes,
    required this.mesasAlAireLibre,
    required this.estacionamiento,
    required this.accesible,
    required this.cambiadorBebes,
    required this.petFriendly,
    required this.cafeEspecialidad,
    required this.brunch,
    required this.desayuno,
    required this.alcohol,
    required this.pasteleriaArtesanal,
    required this.veganFriendly,
    required this.vegetariano,
    required this.sinTacc,
    required this.librosOJuegos,
    required this.onVolver,
  });

  @override
  Widget build(BuildContext context) {
    final caracteristicas = <String>[
      if (tieneWifi) 'Wi-Fi disponible',
      if (aireAcondicionado) 'Aire acondicionado',
      if (enchufes) 'Enchufes disponibles',
      if (mesasAlAireLibre) 'Mesas al aire libre',
      if (estacionamiento) 'Estacionamiento',
      if (accesible) 'Accesible',
      if (cambiadorBebes) 'Cambiador para bebés',
      if (petFriendly) 'Apto mascotas',
      if (cafeEspecialidad) 'Café de especialidad',
      if (brunch) 'Brunch',
      if (desayuno) 'Desayuno',
      if (alcohol) 'Sirve alcohol',
      if (pasteleriaArtesanal) 'Pastelería artesanal',
      if (veganFriendly) 'Opciones veganas',
      if (vegetariano) 'Opciones vegetarianas',
      if (sinTacc) 'Opciones sin gluten / Sin TACC',
      if (librosOJuegos) 'Libros o juegos',
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        24,
        20,
        24,
        32,
      ),
      children: [
        const Text(
          'Revisá antes de enviar',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Color(0xFF111827),
          ),
        ),

        const SizedBox(height: 8),

        const Text(
          'Confirmá que la información de tu cafetería esté correcta.',
          style: TextStyle(
            fontSize: 15,
            height: 1.4,
            color: Colors.black54,
          ),
        ),

        const SizedBox(height: 22),

        if (fotoPrincipal != null) ...[
            ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.file(
                File(fotoPrincipal!.path),
                width: double.infinity,
                height: 190,
                fit: BoxFit.cover,
                ),
            ),

            if (foto2 != null || foto3 != null) ...[
                const SizedBox(height: 12),

                Row(
                children: [
                    if (foto2 != null)
                    Expanded(
                        child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(
                            File(foto2!.path),
                            height: 120,
                            fit: BoxFit.cover,
                        ),
                        ),
                    ),

                    if (foto2 != null && foto3 != null)
                    const SizedBox(width: 12),

                    if (foto3 != null)
                    Expanded(
                        child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(
                            File(foto3!.path),
                            height: 120,
                            fit: BoxFit.cover,
                        ),
                        ),
                    ),
                ],
                ),
            ],
            ],

        const SizedBox(height: 24),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFFE5E7EB),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Datos de la cafetería',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                ),
              ),

              const SizedBox(height: 18),

              _DatoRevision(label: 'Nombre', value: nombre),
              _DatoRevision(label: 'Dirección', value: direccion),
              _DatoRevision(label: 'Localidad', value: localidad),
              _DatoRevision(label: 'Provincia', value: provincia),

              if (instagram.isNotEmpty)
                _DatoRevision(
                  label: 'Instagram',
                  value: instagram,
                ),

              if (googleMaps.isNotEmpty)
                _DatoRevision(
                  label: 'Google Maps',
                  value: googleMaps,
                ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFFE5E7EB),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Qué ofrece',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                ),
              ),

              const SizedBox(height: 14),

              if (caracteristicas.isEmpty)
                const Text(
                  'No seleccionaste características.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: caracteristicas
                      .map(
                        (caracteristica) => Chip(
                          label: Text(caracteristica),
                        ),
                      )
                      .toList(),
                ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 21,
                color: Color(0xFF172C6D),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Tu cafetería se sumará a Gota con el plan Gratis.',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    color: Color(0xFF172C6D),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        OutlinedButton(
          onPressed: onVolver,
          child: const Text('Volver'),
        ),

        const SizedBox(height: 12),

        ElevatedButton(
          onPressed: null,
          child: const Text('Enviar cafetería'),
        ),
      ],
    );
  }
}

class _DatoRevision extends StatelessWidget {
  final String label;
  final String value;

  const _DatoRevision({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 14,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black54,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            value.isEmpty ? '—' : value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }
}