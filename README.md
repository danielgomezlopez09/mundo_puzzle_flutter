# Mundo Puzzle 🧩

Una aplicación educativa Flutter para niños que combina aprendizaje matemático con colección de cartas temáticas. Los jugadores resuelven preguntas educativas para desbloquear piezas de puzzle y coleccionar cartas de 5 mundos diferentes.

## 🎮 Características Principales

### Sistema de Juego
- **Puzzles de 12 Piezas**: Cada carta se desbloquea respondiendo correctamente 12 preguntas
- **6 Opciones de Respuesta**: Sistema de múltiple opción para cada pregunta
- **Cartas Doradas Exclusivas**: Solo se desbloquean con 10 respuestas correctas seguidas
- **Racha de Respuestas**: Contador de respuestas correctas consecutivas

### 5 Mundos Temáticos
1. **Fondo de Coral (Spongy)** - Conteo y números (1-10)
2. **Magia Traviesa (Mika)** - Sumas simples (hasta 20)
3. **Isla Jurásica (Dinos)** - Restas y comparación
4. **Fortaleza Hunter (Samurái)** - Tablas de multiplicar
5. **Valle de la Risa (Tralaleros)** - Divisiones y lógica

### Colección de Cartas
- **225 Cartas Totales**: 45 cartas por mundo
- **3 Rarezas**: Común (Gris), Especial (Azul), Legendaria (Dorada)
- **Álbum Interactivo**: Visualiza tu progreso de colección
- **Desbloqueo Secuencial**: Accede a nuevos mundos completando el anterior

### Perfil del Jugador
- **Estadísticas Personalizadas**: Seguimiento de progreso total
- **Zona de Padres**: Acceso seguro con verificación matemática
- **Historial de Cartas**: Visualiza qué cartas has desbloqueado
- **Progreso por Mundo**: Porcentaje de completitud en cada mundo

## 📱 Requisitos

- Flutter 3.41.9 o superior
- Dart 3.11.5 o superior
- Android SDK (para compilar APK)
- Java 17 o superior

## 🚀 Instalación

### 1. Clonar el Repositorio
```bash
git clone https://github.com/tu-usuario/mundo_puzzle_flutter.git
cd mundo_puzzle_flutter
```

### 2. Instalar Dependencias
```bash
flutter pub get
```

### 3. Ejecutar en Desarrollo
```bash
flutter run
```

### 4. Compilar APK para Producción
```bash
flutter build apk --release
```

La APK compilada se encontrará en: `build/app/outputs/flutter-apk/app-release.apk`

## 📦 Compilación Automática con GitHub Actions

Este proyecto incluye un workflow de GitHub Actions que compila automáticamente la APK en cada push a las ramas `main` o `master`.

### Cómo Funciona:
1. Realiza un push a la rama `main` o `master`
2. GitHub Actions automáticamente:
   - Configura el entorno Flutter
   - Descarga las dependencias
   - Compila la APK en modo release
   - Sube el APK como artifact

### Descargar el APK:
1. Ve a la pestaña "Actions" en tu repositorio GitHub
2. Selecciona el workflow más reciente
3. Descarga el artifact "app-release"

### Crear una Release:
1. Crea un tag: `git tag v1.0.0`
2. Push del tag: `git push origin v1.0.0`
3. GitHub Actions automáticamente creará una release con el APK

## 🏗️ Estructura del Proyecto

```
lib/
├── main.dart                 # Punto de entrada
├── models/
│   └── card_model.dart      # Modelos de datos (Card, Question, etc.)
├── services/
│   └── game_service.dart    # Lógica del juego
├── screens/
│   ├── splash_screen.dart   # Pantalla de carga
│   ├── home_screen.dart     # Pantalla principal
│   ├── world_screen.dart    # Pantalla de mundo
│   ├── game_screen.dart     # Pantalla de juego
│   ├── album_screen.dart    # Álbum de cartas
│   └── player_profile_screen.dart  # Perfil del jugador
└── widgets/
    └── puzzle_widget.dart   # Widget visual del puzzle
```

## 🎯 Mecánica de Juego

### Desbloqueo de Cartas
1. Selecciona un mundo y una carta
2. Responde 12 preguntas educativas
3. Cada respuesta correcta = 1 pieza del puzzle
4. 12 respuestas correctas = Carta desbloqueada

### Sistema de Racha
- Cada respuesta correcta incrementa tu racha
- Una respuesta incorrecta reinicia la racha a 0
- Con 10 respuestas correctas seguidas desbloqueas cartas doradas

### Desbloqueo de Mundos
- El primer mundo (Fondo de Coral) está disponible desde el inicio
- Para desbloquear el siguiente mundo, necesitas 15+ cartas del mundo anterior
- Progresa a través de todos los 5 mundos

## 🔒 Zona de Padres

Acceso seguro para padres mediante:
- Verificación matemática simple (ej: 15 × 2 = ?)
- Opciones para:
  - Ver estadísticas completas
  - Reiniciar el progreso del jugador
  - Información de seguridad y privacidad

## 🎨 Diseño Visual

- **Colores**: Gradientes morados y azules
- **Tipografía**: Material Design
- **Animaciones**: Transiciones suaves y feedback visual
- **Accesibilidad**: Interfaz amigable para niños

## 📊 Datos de Ejemplo

El proyecto incluye datos de ejemplo para todos los mundos y cartas. Para implementar preguntas reales:

1. Edita `lib/services/game_service.dart`
2. Modifica el método `_generateQuestionsForCard()`
3. Añade preguntas específicas por nivel educativo

## 🐛 Solución de Problemas

### La APK no se compila
```bash
# Limpia el proyecto
flutter clean

# Obtén las dependencias nuevamente
flutter pub get

# Intenta compilar de nuevo
flutter build apk --release
```

### Problemas con Android SDK
```bash
# Configura el SDK
flutter config --android-sdk /ruta/al/android-sdk

# Verifica la instalación
flutter doctor
```

## 📝 Licencia

Este proyecto está bajo licencia MIT.

## 👥 Contribuciones

Las contribuciones son bienvenidas. Por favor:
1. Fork el repositorio
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📧 Contacto

Para preguntas o sugerencias, abre un issue en el repositorio.

---

**Mundo Puzzle** - Aprende jugando 🎓🎮
