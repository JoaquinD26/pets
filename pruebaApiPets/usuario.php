<?php
require "database.php"; // Importa la configuración de la base de datos
include "config.php";

// Establece las cabeceras para permitir el acceso desde cualquier origen
header('Content-Type: application/json; charset=UTF-8');
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: *");
header("Access-Control-Max-Age: 3600");

// Si la solicitud es de tipo OPTIONS, envía una respuesta 200 OK y sal
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    header("HTTP/1.1 200 OK");
    exit();
}

// Obtiene una instancia de la conexión a la base de datos
$db = Database::getInstance();
$connection = $db->getConnection();

// Define una respuesta predeterminada
$response = [
    "success" => true,
    "message" => "Operación completada con éxito.",
];

// Obtiene el cuerpo de la solicitud
$data = json_decode(file_get_contents("php://input"));

// Intenta ejecutar las operaciones según el método HTTP
try {
    $connection->exec("SET NAMES 'utf8'");

    if ($_SERVER['REQUEST_METHOD'] === 'POST') {
        if ($data === null) {
            throw new Exception("Datos no válidos o JSON mal formado.");
        }

        PRINT_R($data->nombre);

        $query = "INSERT INTO usuario (nombre) VALUES (:nombre)";
        $stmt = $connection->prepare($query);
        $stmt->bindParam(':nombre', $data->nombre);

        if ($stmt->execute()) {
            $response["message"] = "Usuario insertado correctamente.";
        } else {
            throw new Exception("Error al insertar el usuario.");
        }

    } elseif ($_SERVER['REQUEST_METHOD'] === 'GET') {
        $query = "SELECT * FROM usuario";
        $stmt = $connection->query($query);
        $usuarios = $stmt->fetchAll(PDO::FETCH_ASSOC);

        $response["data"] = $usuarios;

    } else {
        // Método HTTP no válido
        throw new Exception("Método HTTP no válido.");
    }

} catch (Exception $e) {
    // Maneja cualquier error que ocurra durante la ejecución de las operaciones
    $response["success"] = false;
    $response["message"] = "Ocurrió un error al procesar la solicitud: " . $e->getMessage();

    // Si estás depurando, puedes imprimir información sobre el error
    if ($debug) {
        echo $e->getMessage() . PHP_EOL;
        echo $e->getTraceAsString();
    }
} finally {
    // Imprime la respuesta en formato JSON
    echo json_encode($response, JSON_UNESCAPED_UNICODE);
}
