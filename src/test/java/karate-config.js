/**
 * Karate configuration. Runs once, before any feature file.
 *
 * Values here are visible to every scenario as variables: `baseUrl`
 * is used by every feature file's Background step.
 *
 * Overrides, in order of priority:
 *   -Dkarate.baseUrl=https://reqres.in/api   (system property)
 *   -Dkarate.env=ci                          (selects an environment name,
 *                                              currently unused but kept for
 *                                              future per-environment URLs)
 *
 * ReqRes API key (optional): the suite runs without one, against the
 * shared demo key, which has a low daily request limit. A free personal
 * key raises the limit to 250 requests a day. Set it either way:
 *   -Dreqres.api.key=YOUR_KEY   or   REQRES_API_KEY=YOUR_KEY
 * Get one free at https://reqres.in (no card, just an email).
 */
function fn() {
  var env = karate.env || 'dev';
  var config = {
    baseUrl: 'https://reqres.in/api'
  };
  var baseUrlOverride = karate.properties['karate.baseUrl'];
  if (baseUrlOverride) {
    config.baseUrl = baseUrlOverride;
  }
  var apiKey = karate.properties['reqres.api.key'];
  if (!apiKey) {
    apiKey = java.lang.System.getenv('REQRES_API_KEY');
  }
  if (apiKey) {
    karate.configure('headers', { 'x-api-key': apiKey });
  }
  karate.configure('connectTimeout', 10000);
  karate.configure('readTimeout', 30000);
  return config;
}
