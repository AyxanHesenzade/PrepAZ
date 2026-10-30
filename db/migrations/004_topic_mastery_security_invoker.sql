-- topic_mastery view-ı view sahibinin hüquqları ilə işləyirdi və bütün istifadəçilərin sətirlərini qaytarırdı.
-- security_invoker = true: sorğu çağıran istifadəçinin hüquqları və RLS ilə işləyir (answers: yalnız öz cavabları).
-- PostgreSQL 15+ tələb olunur (Supabase-də var). Təkrar işlətmək zərərsizdir.
alter view public.topic_mastery set (security_invoker = true);
