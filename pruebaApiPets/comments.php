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

// Intenta ejecutar las operaciones según el método HTTP
try {
    $connection->exec("SET NAMES 'utf8'");
    if ($_SERVER['REQUEST_METHOD'] === 'GET') {
        // Método GET: Obtener todos los comentarios principales
        $query = "SELECT * FROM comments WHERE parent_comment_id IS NULL";
        $stmt = $connection->query($query);
        $forumPosts = $stmt->fetchAll(PDO::FETCH_ASSOC);

        // Recorrer cada publicación del foro
        $data = [];
        foreach ($forumPosts as $post) {
            // Obtener los comentarios de esta publicación
            $query = "SELECT * FROM comments WHERE parent_comment_id = ?";
            $stmt = $connection->prepare($query);
            $stmt->execute([$post['comment_id']]);
            $comments = $stmt->fetchAll(PDO::FETCH_ASSOC);

            // Añadir comentarios a la publicación
            $post['comments'] = $comments;
            $data[] = $post;
        }

        // Agregar los datos al resultado de la respuesta
        $response['data'] = $data;
    } else {
        // Método HTTP no válido
        throw new Exception("Método HTTP no válido.");
    }
    
} catch (Exception $e) {
    // Maneja cualquier error que ocurra durante la ejecución de las operaciones
    $response["success"] = false;
    $response["message"] = "Ocurrió un error al procesar la solicitud.";
    // Si estás depurando, puedes imprimir información sobre el error
    if ($debug) {
        echo $e->getMessage() . PHP_EOL;
        echo $e->getTraceAsString();
    }
} finally {
    // Imprime la respuesta en formato JSON
    echo json_encode($response, JSON_UNESCAPED_UNICODE);
}
?>