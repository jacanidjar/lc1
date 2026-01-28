# Stage 1: Build
# Estágio 1: Construção
FROM python:3.11-slim as builder

WORKDIR /app
COPY requirements.txt .
# Install dependencies to user directory
# Instala dependências no diretório do usuário
RUN pip install --user --no-cache-dir -r requirements.txt

# Stage 2: Runtime
# Estágio 2: Execução
FROM python:3.11-slim

WORKDIR /app

# Create non-root user for security
# Cria usuário não-root para segurança
RUN adduser --disabled-password --gecos '' appuser
USER appuser

# Copy dependencies from builder
# Copia dependências do estágio de construção
COPY --from=builder /root/.local /home/appuser/.local
ENV PATH=/home/appuser/.local/bin:$PATH

COPY . .

# Expose port 5000
# Expõe a porta 5000
EXPOSE 5000

# Start the application
# Inicia a aplicação
CMD ["python", "app.py"]
