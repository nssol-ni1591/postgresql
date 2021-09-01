package postgresql;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Properties;

public class Example {

	private Connection con;
//	public Connection getConnection() {
//		return con;
//	}
	public Statement createStatement() throws SQLException {
		return con.createStatement();
	}
	public void commit() throws SQLException {
		con.commit();
	}
	public void rollback() throws SQLException {
		con.rollback();
	}
	public void close() throws SQLException {
		con.close();
	}

	public Example(
			String host
			, int port
			, String dbname
			, String user
			, String password
			) throws ClassNotFoundException, SQLException {
		String url = "jdbc:postgresql://" + host + ":" + port + "/" + dbname;

		Properties props = new Properties();
		props.setProperty("user", user);
		props.setProperty("password", password);

		Class.forName("org.postgresql.Driver");
		con = DriverManager.getConnection(url, props);
		con.setAutoCommit(false);
	}

	public static void main(String[] args) {
		Example con = null;
		try {
			con = new Example(
					"192.168.10.135"
					, 5432
					, "testdb"
					, "postgres"
					, "postgres"
					);

//			String sql = "INSERT INTO join_sc.users VALUES (6, 'abc')";
//			int rows = stmt.executeUpdate(sql);
//			System.out.println("insert rows=[" + rows + "]");

			Statement stmt = con.createStatement();
			String sql = "UPDATE join_sc.users SET name=concat(name, 'x') where id=6";
			int rows = stmt.executeUpdate(sql);
			System.out.println("UPDATE rows=[" + rows + "]");
			stmt.close();

			stmt = con.createStatement();
			sql = "SELECT * FROM join_sc.users";
			ResultSet rs = stmt.executeQuery(sql);
			while (rs.next()) {
//				System.out.print("id: " + rs.getInt("id") + "  ");
//				System.out.println("name: " + rs.getString("name"));
				System.out.format("id=[%d] name=[%s](%d)\n",
						rs.getInt("id"), rs.getString("name"), rs.getString("name").length());
			}
			stmt.close();

//			con.commit();
			con.rollback();
		}
		catch (ClassNotFoundException ex) {
			ex.printStackTrace();
		}
		catch (SQLException ex) {
			ex.printStackTrace();
		}
		finally {
			try {
				if (con != null) {
					con.close();
				}
			}
			catch (Exception ex) {
				ex.printStackTrace();
			}
		}
	}

}
