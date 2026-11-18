export GRADLE_OPTS := "-Xmx1g"

gradle := "./gradlew --no-daemon -Dorg.gradle.jvmargs=-Xmx1536m"
engine := `sed -n 's/^reseam = "\(.*\)"/\1/p' gradle/libs.versions.toml`
reseam := "build/engine/reseam"

check:
    {{ gradle }} :composeApp:assembleDebug :composeApp:compileKotlinJvm -PmanagerVersion=0.0.1

release tag:
    curl -fsSL --create-dirs -o {{ reseam }} https://cdn.reseam.app/engine/v{{ engine }}/reseam-linux-x64
    chmod +x {{ reseam }}
    mkdir -p build
    if [ -n "$ANDROID_KEYSTORE_B64" ]; then echo "$ANDROID_KEYSTORE_B64" | base64 -d > build/keystore.jks; else keytool -genkeypair -v -keystore build/keystore.jks -alias reseam -keyalg RSA -keysize 2048 -validity 10000 -storepass 123456 -keypass 123456 -dname "CN=Reseam, OU=Dev, O=Reseam, L=VN, S=VN, C=VN"; fi
    RESEAM_KEYSTORE="$PWD/build/keystore.jks" {{ gradle }} :composeApp:stageRelease -PmanagerVersion={{ tag }}
