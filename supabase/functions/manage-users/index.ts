import { serve } from "https://deno.land/std/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

serve(async (req) => {
  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SERVICE_ROLE_KEY")!,
  );

  try {
    // =======================
    // READ: List semua user (aktif & nonaktif)
    // =======================
    if (req.method === "GET") {
      const { data, error } = await supabase.auth.admin.listUsers();
      if (error) throw error;

      const users = data.users.map((u) => ({
        id: u.id,
        email: u.email,
        phone: u.phone,
        raw_user_meta_data: u.user_metadata || {},
      }));

      return new Response(JSON.stringify({ users }), {
        headers: { "Content-Type": "application/json" },
      });
    }

    // =======================
    // CREATE: Tambah user baru
    // =======================
    else if (req.method === "POST") {
      const body = await req.json();
      const { email, password, role, name } = body;

      const { data, error } = await supabase.auth.admin.createUser({
        email,
        password,
        user_metadata: { role, name, is_active: true },
      });
      if (error) throw error;

      return new Response(JSON.stringify({ user: data.user }), {
        headers: { "Content-Type": "application/json" },
      });
    }

    // =======================
    // UPDATE: Update user
    // =======================
    else if (req.method === "PUT") {
      const body = await req.json();
      const { id, email, password, role, name, is_active } = body;

      const { data, error } = await supabase.auth.admin.updateUserById(id, {
        email,
        password,
        user_metadata: { role, name, is_active },
      });
      if (error) throw error;

      return new Response(JSON.stringify({ user: data.user }), {
        headers: { "Content-Type": "application/json" },
      });
    }

    // =======================
    // DELETE: Soft delete (nonaktifkan)
    // =======================
    else if (req.method === "DELETE") {
      const body = await req.json();
      const { id } = body;

      const { data, error } = await supabase.auth.admin.updateUserById(id, {
        user_metadata: { is_active: false },
      });
      if (error) throw error;

      return new Response(
        JSON.stringify({ message: `User ${id} has been deactivated` }),
        { headers: { "Content-Type": "application/json" } },
      );
    }

    // =======================
    // METHOD NOT ALLOWED
    // =======================
    else {
      return new Response("Method Not Allowed", { status: 405 });
    }

  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message || error }),
      { status: 500, headers: { "Content-Type": "application/json" } },
    );
  }
});
