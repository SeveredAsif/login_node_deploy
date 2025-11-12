import React, { useState } from 'react'

// Behind nginx reverse proxy, use same-origin requests
const apiBase = ''

export default function App() {
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [token, setToken] = useState(null)
  const [message, setMessage] = useState('')

  async function register() {
    const res = await fetch(`${apiBase}/api/register`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email, password })
    })
    const data = await res.json()
    setMessage(JSON.stringify(data))
  }

  async function login() {
    const res = await fetch(`${apiBase}/api/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email, password })
    })
    const data = await res.json()
    if (data.token) {
      setToken(data.token)
      setMessage('Logged in')
    } else {
      setMessage(JSON.stringify(data))
    }
  }

  async function profile() {
    const res = await fetch(`${apiBase}/api/profile`, {
      headers: { Authorization: `Bearer ${token}` }
    })
    const data = await res.json()
    setMessage(JSON.stringify(data))
  }

  return (
    <div style={{ padding: 20, fontFamily: 'Arial, sans-serif' }}>
      <h2>Login App</h2>
      <div style={{ maxWidth: 420 }}>
        <input value={email} onChange={e => setEmail(e.target.value)} placeholder="email" />
        <br />
        <input type="password" value={password} onChange={e => setPassword(e.target.value)} placeholder="password" />
        <br />
        <button onClick={register}>Register</button>
        <button onClick={login}>Login</button>
        <button onClick={profile} disabled={!token}>Profile</button>
        <div style={{ marginTop: 12, whiteSpace: 'pre-wrap' }}>{message}</div>
      </div>
    </div>
  )
}
