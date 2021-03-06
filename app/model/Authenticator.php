<?php

namespace NetteAddons\Model;

use Nette,
	Nette\Utils\Strings,
	Nette\Database\SqlLiteral,
	Nette\Database\Table\ActiveRow,
	Nette\Security as NS,
	NetteAddons\Utils\CurlRequestFactory;



/**
 * Users authenticator.
 */
class Authenticator extends Nette\Object implements NS\IAuthenticator
{
	const EXTERNAL_URL = 'http://forum.nette.org/cs/login.php?action=in';

	/** @var Users */
	private $users;

	/** @var \NetteAddons\Utils\CurlRequestFactory */
	private $curlFactory;



	/**
	 * @param  Users
	 * @param  \NetteAddons\Utils\CurlRequestFactory
	 */
	public function __construct(Users $users, CurlRequestFactory $curlFactory)
	{
		$this->users = $users;
		$this->curlFactory = $curlFactory;
	}



	/**
	 * Performs an authentication
	 *
	 * @param  array
	 * @return \Nette\Security\Identity
	 * @throws \Nette\Security\AuthenticationException
	 */
	public function authenticate(array $credentials)
	{
		list($username, $password) = $credentials;
		$user = $this->users->findOneByName($username);

		if (!$user) {
			if (!$user = $this->authenticateExternal($username, $password)) {
				throw new NS\AuthenticationException("User '$username' not found.", self::IDENTITY_NOT_FOUND);
			}
		}

		if ($user->password !== $this->calculateHash($password)) {
			throw new NS\AuthenticationException("Invalid password.", self::INVALID_CREDENTIAL);
		}

		if (empty($user->created)) {
			$this->onFirstLogin($user);
		}

		return $this->users->createIdentity($user);
	}



	/**
	 * Computes password hash.
	 *
	 * @param  string
	 * @return string
	 */
	public function calculateHash($password)
	{
		return sha1($password);
	}



	/**
	 * Called when user logs in to the portal for the first time, so that we can initialize some columns
	 * @param  ActiveRow
	 */
	private function onFirstLogin(ActiveRow $user)
	{
		$data = array(
			'created' => new SqlLiteral('NOW()'),
			'apiToken' => Strings::random(),
		);
		$table = $user->getTable()->getConnection()->table('users_details');
		if ($detail = $table->find($user->id)) {
			$detail->update($data);
		} else {
			$data['id'] = $user->id;
			$table->insert($data);
		}
	}



	/**
	 * Authenticate again external site (hack ;)
	 * @param  string
	 * @param  string
	 * @return bool
	 */
	private function authenticateExternal($username, $password)
	{
		$req = $this->curlFactory->create(self::EXTERNAL_URL);
		$req->setOption(CURLOPT_POST, TRUE);
		$req->setOption(CURLOPT_POSTFIELDS, http_build_query(array(
			'form_sent' => 1,
			'req_name' => $username,
			'req_password' => $password,
			'redirect_url' => 'index.php',
		)));
		$req->setOption(CURLOPT_COOKIEFILE, ''); // needs to be here to store cookies between redirects

		try {
			$html = $req->execute();
		} catch(\NetteAddons\Utils\HttpException $e) { // auth failure
			return FALSE;
		}

		if (!$match = Strings::match($html, '~<a href="profile\.php\?id=(\d+)" title=~')) {
			return FALSE;
		}
		$id = $match[1];

		return $this->users->createUser($id, $username, $password);
	}

}
