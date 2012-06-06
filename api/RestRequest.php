<?php
class RestRequest
{
	private $request_vars;
	private $data;
	private $http_accept;
	private $method;

	public function __construct()
	{
		$this->request_vars		= array();
		$this->data				= '';
		$this->http_accept		= ( isset($_SERVER['HTTP_ACCEPT']) && strpos($_SERVER['HTTP_ACCEPT'], 'json')) ? 'json' : 'xml';
		$this->method			= 'get';
	}

	public function setData($data)
	{
		$this->data = $data;
	}

	public function setMethod($method)
	{
		$this->method = $method;
	}

	public function setRequestVars($request_vars)
	{
		$this->request_vars = $request_vars;
	}

	public function getData()
	{
		return $this->data;
	}

	public function getMethod()
	{
		return $this->method;
	}

	public function getHttpAccept()
	{
		return $this->http_accept;
	}

	public function getRequestVars()
	{
		return $this->request_vars;
	}

	public function getId()
	{
		if ( isset($this->request_vars['id']) ) {
			return $this->request_vars['id'];
		} elseif ($this->method == "delete" && isset($this->request_vars[0]) ) {
			return $this->request_vars[0];
		} else {
			return false;
		}
	}

	public function getTable()
	{
		if ( isset($this->request_vars['table']) ) {
			return $this->request_vars['table'];
		} else {
			return false;
		}
	}
}
?>