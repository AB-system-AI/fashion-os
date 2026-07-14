import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.49.1';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const { email, success, failure_reason, ip_address, user_agent } = await req.json();

    if (!email) {
      return new Response(JSON.stringify({ error: 'Email required' }), {
        status: 400,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
    );

    const { data: locked } = await supabaseAdmin.rpc('is_login_locked', { p_email: email });

    if (locked && !success) {
      await supabaseAdmin.from('login_attempts').insert({
        email: email.toLowerCase(),
        ip_address,
        user_agent,
        success: false,
        failure_reason: 'account_locked',
      });

      return new Response(JSON.stringify({ locked: true }), {
        status: 429,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    await supabaseAdmin.from('login_attempts').insert({
      email: email.toLowerCase(),
      ip_address,
      user_agent,
      success: success ?? false,
      failure_reason,
    });

    if (!success) {
      await supabaseAdmin.rpc('record_security_event', {
        p_user_id: null,
        p_event_type: 'login_failed',
        p_ip_address: ip_address,
        p_user_agent: user_agent,
        p_metadata: { email },
      });
    }

    return new Response(JSON.stringify({ locked: false }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  } catch (err) {
    return new Response(JSON.stringify({ error: String(err) }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  }
});
