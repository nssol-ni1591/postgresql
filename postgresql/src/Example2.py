#!/usr/bin/python2.7

import psycopg2
from __builtin__ import len


class Example:

	con = None

	def __init__(self, host, port, dbname, user, password):
		self.con = self.connect(host, port, dbname, user, password)

	def connect(self, host, port, dbname, user, password):
		url = "dbname=" + dbname
		url += " host=" + host
		url += " port=" + str(port)
		url += " user=" + user
		url += " password=" + password
		con = psycopg2.connect(url)
		con.autocommit = False
		return con

	def cursor(self):
		return self.con.cursor();

	def commit(self):
		return self.con.commit();

	def rollback(self):
		return self.con.rollback();

	def close(self):
		return self.con.close();


if __name__ == '__main__':

	con = Example(
		"192.168.10.135"
		, 5432
		, "testdb"
		, "postgres"
		, "postgres"
	)

	cur = con.cursor()

	cur.execute("UPDATE join_sc.users SET name=concat(name, 'x') WHERE id=5")

	con.rollback()

	cur.execute("SELECT * FROM join_sc.users")

	for row in cur:
		print("id=[" + str(row[0]) + "] name=[" + row[1] + "](" + str(len(row[1])) + ")")

	con.commit()

	con.close()
