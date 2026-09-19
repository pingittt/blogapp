# BlogAppQa — Express (TypeScript + Drizzle + MySQL) + Flutter

## Struktur

```
BlogAppQa/
├── Server/                 
│   ├── src/
│   │   ├── index.ts        
│   │   ├── config/
│   │   │   ├── db.ts        
│   │   │   ├── schema.ts    
│   │   │   └── cloudinary.ts
│   │   ├── controllers/     
│   │   ├── routes/          
│   │   ├── middleware/      
│   │   └── utils/jwt.ts
│   ├── Rekomedasi.json      
│   └── .env
└── mobile/                  
    └── lib/
        ├── main.dart
        ├── models/          
        ├── services/        
        └── screens/         
| Package | `http`, `shared_preferences`, `image_picker` di `pubspec.yaml` |
| REST API di Flutter | `mobile/lib/services/api_service.dart` |
| Implementasi REST API (tampilkan data) | `FutureBuilder` di `home_screen.dart`, `post_detail_screen.dart` |
