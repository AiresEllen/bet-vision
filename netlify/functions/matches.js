exports.handler = async function (event) {
  try {
    const apiKey =
      process.env.API_FOOTBALL_KEY || process.env.FOOTBALL_API_KEY;

    if (!apiKey) {
      return {
        statusCode: 500,
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          error:
            "Configure API_FOOTBALL_KEY ou FOOTBALL_API_KEY no Netlify para carregar os jogos.",
        }),
      };
    }

    const query = event.queryStringParameters || {};
    const today = new Date().toISOString().slice(0, 10);

    const params = new URLSearchParams();
    params.set("date", query.date || today);
    params.set("timezone", query.timezone || "America/Sao_Paulo");

    if (query.league) params.set("league", query.league);
    if (query.season) params.set("season", query.season);
    if (query.live) params.set("live", query.live);

    const url = `https://v3.football.api-sports.io/fixtures?${params.toString()}`;

    const response = await fetch(url, {
      headers: {
        "x-apisports-key": apiKey,
      },
    });

    const text = await response.text();

    return {
      statusCode: response.status,
      headers: { "Content-Type": "application/json" },
      body: text,
    };
  } catch (error) {
    return {
      statusCode: 500,
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        error: "Falha ao consultar a API de futebol.",
        details: String(error),
      }),
    };
  }
};
