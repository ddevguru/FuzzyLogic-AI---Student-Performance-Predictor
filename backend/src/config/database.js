const { Pool } = require('pg');
require('dotenv').config();

let poolConfig;

if (process.env.DATABASE_URL) {
  poolConfig = {
    connectionString: process.env.DATABASE_URL,
    ssl: process.env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : false,
  };
} else {
  poolConfig = {
    host: process.env.DB_HOST || 'localhost',
    port: parseInt(process.env.DB_PORT || '5432', 10),
    user: process.env.DB_USER || 'postgres',
    password: process.env.DB_PASSWORD || 'postgres',
    database: process.env.DB_NAME || 'fuzzy_student_db',
  };
}

let pool = new Pool(poolConfig);
let isPgConnected = false;

// In-Memory store fallback if PG connection fails
const inMemoryStore = {
  users: [],
  student_profiles: [],
  performance_records: [],
  fuzzy_results: [],
};

async function initDb() {
  // First, check if database exists or try connecting to default 'postgres' database to create DB
  try {
    const adminPool = new Pool({
      ...dbConfig,
      database: 'postgres',
    });
    
    const res = await adminPool.query(
      `SELECT 1 FROM pg_database WHERE datname = $1`,
      [dbConfig.database]
    );
    
    if (res.rowCount === 0) {
      console.log(`Database '${dbConfig.database}' does not exist. Creating...`);
      await adminPool.query(`CREATE DATABASE "${dbConfig.database}"`);
      console.log(`Database '${dbConfig.database}' created successfully.`);
    }
    await adminPool.end();
  } catch (err) {
    console.warn('Could not auto-create database via admin connection:', err.message);
  }

  // Connect to target database
  try {
    const client = await pool.connect();
    console.log(`Connected to PostgreSQL database: ${dbConfig.database}`);
    isPgConnected = true;

    // Ensure extension for UUID generation exists
    await client.query(`CREATE EXTENSION IF NOT EXISTS "pgcrypto";`);

    // Create users table
    await client.query(`
      CREATE TABLE IF NOT EXISTS users (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        name VARCHAR(100) NOT NULL,
        email VARCHAR(150) UNIQUE NOT NULL,
        password_hash TEXT NOT NULL,
        role VARCHAR(20) DEFAULT 'student',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);

    // Create student_profiles table
    await client.query(`
      CREATE TABLE IF NOT EXISTS student_profiles (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        user_id UUID REFERENCES users(id) ON DELETE CASCADE,
        roll_number VARCHAR(50),
        course VARCHAR(100),
        semester INTEGER,
        department VARCHAR(100),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);

    // Create performance_records table
    await client.query(`
      CREATE TABLE IF NOT EXISTS performance_records (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        student_id UUID REFERENCES users(id) ON DELETE CASCADE,
        attendance DECIMAL(5,2),
        test_score DECIMAL(5,2),
        assignment_score DECIMAL(5,2),
        study_hours DECIMAL(5,2),
        performance_score DECIMAL(5,2),
        performance_level VARCHAR(30),
        risk_level VARCHAR(30),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);

    // Create fuzzy_results table
    await client.query(`
      CREATE TABLE IF NOT EXISTS fuzzy_results (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        performance_id UUID REFERENCES performance_records(id) ON DELETE CASCADE,
        attendance_low DECIMAL(5,4),
        attendance_medium DECIMAL(5,4),
        attendance_high DECIMAL(5,4),
        test_low DECIMAL(5,4),
        test_medium DECIMAL(5,4),
        test_high DECIMAL(5,4),
        assignment_low DECIMAL(5,4),
        assignment_medium DECIMAL(5,4),
        assignment_high DECIMAL(5,4),
        study_low DECIMAL(5,4),
        study_medium DECIMAL(5,4),
        study_high DECIMAL(5,4),
        defuzzified_score DECIMAL(5,2),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);

    client.release();
    console.log('Database tables verified/created successfully.');
  } catch (err) {
    console.error('PostgreSQL connection failed:', err.message);
    console.log('Using in-memory data store for fallback execution.');
    isPgConnected = false;
  }
}

async function query(text, params) {
  if (isPgConnected) {
    return pool.query(text, params);
  } else {
    // Basic in-memory fallback query handler
    throw new Error('Database disconnected. In-memory fallback available via DAO helpers.');
  }
}

module.exports = {
  pool,
  query,
  initDb,
  isPgConnected: () => isPgConnected,
  inMemoryStore,
};
