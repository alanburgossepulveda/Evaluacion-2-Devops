#!/usr/bin/env bash
# Auditoría de cumplimiento: termina con error si se incumple alguna política.
fail=0

check() {
  if eval "$2" >/dev/null 2>&1; then
    echo "OK     $1"
  else
    echo "FALLA  $1"
    fail=1
  fi
}

check "El archivo .env no está versionado"            '! git ls-files --error-unmatch .env'
check ".gitignore excluye los archivos .env"          'grep -qx ".env" .gitignore'
check "Dockerfile usa un usuario no root"             'grep -q "^USER " Dockerfile'
check "Dockerfile define HEALTHCHECK"                 'grep -q "^HEALTHCHECK" Dockerfile'
check "Deployment define límites de recursos"         'grep -q "limits:" k8s/app.yaml'
check "Deployment define sondas de salud"             'grep -q "readinessProbe:" k8s/app.yaml && grep -q "livenessProbe:" k8s/app.yaml'
check "No hay Secrets escritos en los manifiestos"    '! grep -rq "kind: Secret" k8s/'
check "El workflow declara permisos mínimos"          'grep -q "^permissions:" .github/workflows/ci-cd.yml'
check "Dependabot está configurado"                   'test -f .github/dependabot.yml'
check "Las excepciones de Snyk tienen vencimiento"    'grep -q "expires:" .snyk'
check "JaCoCo exige cobertura mínima (70 %)"          'grep -Eq "<minimum>0\.7" pom.xml'

if [ "$fail" -ne 0 ]; then
  echo "::error title=Cumplimiento::La auditoría encontró políticas incumplidas. Pipeline bloqueado."
  exit 1
fi
echo "Auditoría de cumplimiento: todas las políticas se cumplen."