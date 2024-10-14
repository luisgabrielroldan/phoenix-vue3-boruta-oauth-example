# Phoenix + Vue 3 example application

## Overview

This is a simple full-stack application built with Phoenix and Vue 3. The backend API is generated using OpenAPI specifications and the frontend uses the Swagger TypeScript API Generator to auto-generate TypeScript types and API client code. OAuth2 authentication is implemented via Boruta, and the frontend state management is handled using Pinia. The project is styled with Tailwind CSS.


## Stack

- [Phoenix 1.7](https://hexdocs.pm/phoenix/1.7.14/Phoenix.html)
- [Vue 3](https://vuejs.org/)
- [Pinia](https://pinia.vuejs.org/)
- [Open API Spec](https://hexdocs.pm/open_api_spex)
- [Swagger Typescript API Generator](https://www.npmjs.com/package/swagger-typescript-api)
- [Boruta (OAuth2)](https://hexdocs.pm/boruta)
- [Tailwind CSS](https://tailwindcss.com/)


## Getting started

1. To start this project:
```bash
docker compose up
```

2. Create the default user:
```bash
docker compose exec api mix run priv/repo/seeds.exs
```

3. Visit `http://localhost:3000`

4. Login with the default user credentials: `admin@example.com` / `password`

## License

This project is licensed under the MIT License.


