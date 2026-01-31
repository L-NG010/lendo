import { serve } from "https://deno.land/std/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

// Header CORS
const corsHeaders = {
  "Access-Control-Allow-Origin": "*", // atau ganti domain produksi
  "Access-Control-Allow-Methods": "GET, POST, PUT, DELETE, OPTIONS",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

serve(async (req) => {
  // Handle preflight request
  if (req.method === "OPTIONS") {
    return new Response(null, { headers: corsHeaders });
  }

  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SERVICE_ROLE_KEY")!,
  );

  try {

    // READ USERS
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
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // CREATE USER
    if (req.method === "POST") {
      const body = await req.json();
      const { email, password, role, name } = body;

      const { data, error } = await supabase.auth.admin.createUser({
        email,
        password,
        user_metadata: { role, name, is_active: true },
      });
      if (error) throw error;

      return new Response(JSON.stringify({ user: data.user }), {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // UPDATE USER
    if (req.method === "PUT") {
      const body = await req.json();
      const { id, email, password, role, name, is_active } = body;

      const { data, error } = await supabase.auth.admin.updateUserById(id, {
        email,
        password,
        user_metadata: { role, name, is_active },
      });
      if (error) throw error;

      return new Response(JSON.stringify({ user: data.user }), {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // DELETE USER (soft delete)
    if (req.method === "DELETE") {
      const body = await req.json();
      const { id } = body;

      const { data, error } = await supabase.auth.admin.updateUserById(id, {
        user_metadata: { is_active: false },
      });
      if (error) throw error;

      return new Response(
        JSON.stringify({ message: `User ${id} deactivated` }),
        { headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    return new Response("Method Not Allowed", { status: 405 });

  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  }
});
