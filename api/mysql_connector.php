<?php
//error_reporting(0);

require_once("db_connection.php");
require_once("RestUtils.php");
require_once("RestRequest.php");
require_once("Logging.php");

$request = RestUtils::processRequest();

$db_connection = connect_db();

switch($request->getMethod())
{
	case 'get':
		// GET CONTENT FOR MARKER_ID

		$id = mysql_real_escape_string( $request->getId() );
		$table = mysql_real_escape_string( $request->getTable() );

		if ( $id ) {
			$query = "SELECT * FROM $table WHERE id=$id";
			$result = mysql_query($query);

			if ($error = mysql_error()) {
				$output->result = "error";
				$output->error = mysql_error();
				RestUtils::sendResponse(500, json_encode($output), 'application/json');
			} else {
				$object = mysql_fetch_object($result);
				$output = json_decode($object->data);
				RestUtils::sendResponse(200, json_encode($output), 'application/json');
			}
		} else {
			$query = "SELECT * FROM $table ORDER BY position ASC, id ASC";
			$result = mysql_query($query);

			$output = new StdClass();
			if ($error = mysql_error()) {
				$output->result = "error";
				$output->error = mysql_error();
				RestUtils::sendResponse(500, json_encode($output), 'application/json');
			} else {
				$output = array();
				while( $row = mysql_fetch_object($result) ) {
					array_push( $output, json_decode($row->data) );
				}
				RestUtils::sendResponse(200, json_encode($output), 'application/json');
			}
		}
		
		

		
		break;
	
	case 'post':
		// INSERT NEW CONTENT
		$table = mysql_real_escape_string( $request->getTable() );
		$post = $request->getRequestVars();
		
		var_dump(($post));

		$data = mysql_real_escape_string( isset($post) ? stripslashes($post) : "" );
		$title = "";//json_decode($data)["title"];
		


		$query = "INSERT INTO $table SET
				  data='$data',
				  title='$title'";
		$result = mysql_query($query);
		$insert_id = mysql_insert_id();

		$logging = new Logging();
		$logging->log($query);

		$output = new StdClass();
		if ($error = mysql_error()) {
			$output->result = "error";
			$output->error = mysql_error();
			RestUtils::sendResponse(500, json_encode($output), 'application/json');
		} else {
			$output->result = "inserted content";
			$output->id = $insert_id;


			$query = "SELECT * FROM $table WHERE id=$id";
			$result = mysql_query($query);

			$output = mysql_fetch_object($result);
			RestUtils::sendResponse(201, json_encode($output), 'application/json');
		}

		break;

	case 'put':
		// UPDATE CONTENT
		$data = $request->getRequestVars();

		$content_id = mysql_real_escape_string( isset($data['content_id'])? stripslashes($data['content_id']):""  );
		$marker_id = mysql_real_escape_string( isset($data['marker_id'])? stripslashes($data['marker_id']):""  );
		$contentType = mysql_real_escape_string( isset($data['contentType'])? stripslashes($data['contentType']):""  );
		$url = mysql_real_escape_string( isset($data['url'])? stripslashes($data['url']):"" );
		$title = mysql_real_escape_string( isset($data['title'])? stripslashes($data['title']):"" );
		$description = mysql_real_escape_string( isset($data['description'])? stripslashes($data['description']):"" );
		$author = mysql_real_escape_string( isset($data['author'])? stripslashes($data['author']):"" );
		$publish = mysql_real_escape_string( isset($data['publish'])? stripslashes($data['publish']):"" );
		$category = mysql_real_escape_string( isset($data['category'])? stripslashes($data['category']):"" );

		$query = "UPDATE content SET
				  marker_id=$marker_id,
				  contentType='$contentType',
				  url='$url',
				  title='$title',
				  description='$description',
				  author='$author',
				  publish='$publish',
				  category='$category'
				  WHERE id=$content_id";
		$result = mysql_query($query);

		$output = new StdClass();
		if ($error = mysql_error()) {
			$output->result = "error";
			$output->error = mysql_error();
		} else {
			$output->result = "updated content";
			$output->id = $content_id;
		}
		
		$logging = new Logging();
		$logging->log($query);

		RestUtils::sendResponse(200, json_encode($output), 'application/json');
		break;

	case 'delete':
		$output = new StdClass();

		if ($id = $request->getId()) {
			$content_id = mysql_real_escape_string( $id );

			$query = "DELETE FROM content WHERE id=$content_id";
			$result = mysql_query($query);

			if ($error = mysql_error()) {
				$output->result = "error";
				$output->error = mysql_error();
			} else {
				$output->result = "deleted content";
				$output->id = $id;
			}
			
			$logging = new Logging();
			$logging->log($query);

			RestUtils::sendResponse(200, json_encode($output), 'application/json');
		} else {
			$output->result = "error";
			$output->message = "id not specified";
			RestUtils::sendResponse(400, json_encode($output), 'application/json');
		}
		break;
}

close_db($db_connection);

?>