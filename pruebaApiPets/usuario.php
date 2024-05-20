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
    "message" => "Forum posts loaded successfully.",
];

$data = json_decode(file_get_contents("php://input"));

// Intenta ejecutar las operaciones según el método HTTP
try {
    $connection->exec("SET NAMES 'utf8'");
    if ($_SERVER['REQUEST_METHOD'] === 'POST') {
        // Método GET: Obtener todos los comentarios principales
        $query = "INSERT into usuario (nombre) value (:nombre)";
        $stmt->bindParam(':nombre', $data->nombre);
        $stmt = $connection->query($query);
        $forumPosts = $stmt->fetchAll(PDO::FETCH_ASSOC);

        $response = $forumPosts;

    } elseif ($_SERVER['REQUEST_METHOD'] === 'GET') {
       
        $query = "SELECT * From usuario";
        $stmt = $connection->query($query);
        $forumPosts = $stmt->fetchAll(PDO::FETCH_ASSOC);

        $response = $forumPosts;
    } else {
        // Método HTTP no válido
        throw new Exception("Método HTTP no válido.");
    }
    
} catch (Exception $e) {
    // Maneja cualquier error que ocurra durante la ejecución de las operaciones
    $response["success"] = false;
    $response["message"] = "Ocurrió un error al procesar la solicitud.";
    // Si estás depurando, puedes imprimir información sobre el error
    // if ($debug) {
    //     echo $e->getMessage() . PHP_EOL;
    //     echo $e->getTraceAsString();
    // }
} finally {
    // Imprime la respuesta en formato JSON
    echo json_encode($response, JSON_UNESCAPED_UNICODE);
}
?>