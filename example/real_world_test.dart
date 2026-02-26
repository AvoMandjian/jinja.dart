// ignore_for_file: avoid_print

import 'dart:async';

import 'package:jinja/jinja.dart';

import 'get_jinja.dart';

final jinjaScript = """{{print("STEP 1:")}}
{% set login_response = jinja_action("handle_on_login","db")%}

{{print("STEP 2:")}}
    {# {% if login_response and login_response.workflow_results and login_response.workflow_results.login and login_response.workflow_results.login.login_user %} #}
            {{print("STEP 3:")}}
        {% set login_user = login_response.workflow_results.login.login_user %}
            {{print("STEP 4:")}}
        {# {% if login_user.detail is not null and login_user.detail != '' %} #}
            {{print("STEP 5:")}}
            {% set error_message = login_user.detail %}
            {% set dataToSend = {"error_message": error_message} | tojson %}
            {{print("STEP 6:")}}
            {% do jinja_action("show_error_message","app", dataToSend) %}
            {{print("STEP 7:")}}
        {# {% endif %} #}
    {# {% endif %} #}

{
  "workflow_actions": [
    {% if login_response and login_response.workflow_results and login_response.workflow_results.login and login_response.workflow_results.login.login_user and (login_response.workflow_results.login.login_user.token is not null and login_response.workflow_results.login.login_user.token != '') %}
    {% set dataToSend = {"key": 'userToken', "value": login_response.workflow_results.login.login_user.token} | tojson %}
    {% do jinja_action("save_to_secure_storage","app", dataToSend) %}
    {
      "json_in_schema_id": "get_data_from_db_json_in_schema",
      "json_out_schema_id": "get_data_from_db_json_out_schema",
      "set_page": {
        "properties": {
          "column_id": "column_2",
          "page_id": "jframe_scripts_list",
          "cell_value": "output_doc_jframe_scripts_list",
          "table_name": "content",
          "column_name": "content_id"
        }
      }
    }
    {% endif %}
  ]
}
""";
final jinjaData = {
  'jinja_script_id': '5c61aa50-d001-487b-8c12-5b2380bdedd4',
  'output_type': '',
  'cell_value': 'code_editor',
  'table_name': 'content',
  'column_name': 'content_id',
  'widget_id': 'code_editor',
  'clear_data': true,
  'page_id': 'code_editor',
  'jinja_script_by_id': {
    'jinja_script': {
      'data': {
        'text':
            'e3sKICBydW5fZGF0YV9zb3VyY2UoJ2dldF9jb3VudCcsIHsnY29udGVudF90eXBlJzonY29udGVudF90eXBlX2ppbmphX3NjcmlwdCd9KQp9fQoKCnt7CiAgcnVuX2RhdGFfc291cmNlKCdnZXRfY291bnQnKQp9fQoKe3sKICAgIHJ1bl9kYXRhX3NvdXJjZSgnc3RvcmVfc2luZ2xlX2FwcF9sYXlvdXQnLCB7J2NhdGVnb3J5X2lkJzondG9wX2ZyZWVfYXBwcyd9ICkKfX0KCnt7CiAgICBydW5fZGF0YV9zb3VyY2UoJ2dldF9yYWRpb19hcHBfamZyYW1lJykKfX0KClRISVMgSVMgVEhFIERBVEEKe3sgZGF0YSB9fQpUSElTIElTIFRIRSBEQVRB',
        'column_id': 'jinja_script',
      },
      'ui_widget': {
        'ui_widget_id': 'list_row_text',
      },
    },
    'jinja_data': {
      'output_type': 'html',
    },
    'parent_id': null,
  },
  'jinja_ide_ai_agents': [
    {
      'id': '1',
      'input_schema': {
        'schema': 'http://json-schema.org/draft-07/schema#',
        'title': 'Chat LLM Input',
        'description': 'Schema for input to the Chat LLM for general chitchat and Q&A.',
        'type': 'object',
        'properties': {
          'model': {
            'description': 'Model to use.',
            'type': 'string',
          },
          'agent_id': {
            'description': 'Unique identifier for the specific agent or role generating the response.',
            'type': 'string',
            'enum': [
              'solver',
              'proofreader',
              'chat',
              'vibe',
              'context',
              'spec',
            ],
          },
          'user_id': {
            'description': 'Unique identifier for the user, used for tracking and personalization.',
            'type': 'string',
          },
          'query': {
            'description': "The user's freeform text query or message. This is the primary input from the user.",
            'type': 'string',
          },
          'session_id': {
            'description': 'Unique identifier for the current conversation session, used to maintain context.',
            'type': 'string',
          },
          'timestamp': {
            'description': "Timestamp of the user's query in ISO 8601 format, used for logging and ordering.",
            'type': 'string',
            'format': 'date-time',
          },
          'metadata': {
            'description': 'An open-ended object for any additional metadata.',
            'type': 'object',
          },
          'selected': {
            'description':
                'Any text or code selected by the user for context. This can be used to provide additional information for the query.',
            'type': 'string',
          },
          'history': {
            'description': 'A list of color updates.',
            'type': 'array',
            'items': {
              'type': 'object',
              'properties': {
                'agent': {
                  'description': "The user's message.",
                  'type': 'string',
                },
                'user': {
                  'description': "The agent's message",
                  'type': 'string',
                },
              },
              'required': [
                'agent',
                'user',
              ],
            },
          },
        },
        'required': [
          'query',
          'user_id',
          'session_id',
          'timestamp',
          'metadata',
        ],
      },
      'output_schema': {
        'schema': 'http://json-schema.org/draft-07/schema#',
        'title': 'Chat LLM Output',
        'description': 'Schema for output to the Chat LLM for general chitchat and Q&A.',
        'type': 'object',
        'properties': {
          'name': {
            'description':
                'The name of the LLM. This should be a human-readable identifier for the agent responding. Its purpose is to clearly attribute the source of the response.',
            'type': 'string',
          },
          'response': {
            'description':
                "The LLM's text response to the user's query. This is a user-facing, conversational reply that should summarize the action taken and provide a high-level overview of the changes.",
            'type': 'string',
          },
        },
        'required': [
          'name',
          'response',
        ],
      },
      'jinja_template':
          "{# This Jinja template formats a JSON object matching the chat-IN.json schema #} {# into a clean, human-readable prompt for a Large Language Model (LLM). #} {# It prioritizes the user's query and any selected text for context, #} {# while omitting irrelevant metadata like user_id and session_id. #} You are an expert Jinja developer. {{ name }} Agent Role: Conversational Partner Purpose: You are to engage in a helpful dialogue with the user. Your task is to discuss project ideas, answer any questions they have, and provide clear and concise explanations and documentation especially pertaining to Jinja. You should be direct and responsive, acting as a knowledgeable guide throughout the project.  {# Display conversation history if available #} {% if history %} **Conversation History:** {% for message in history %} You: {{- message.content.agent }} Me: {{- message.content.user }} {% endif %} {% endfor %} --- {% endif %}  {# The main query from the user. #} {{ query }}  {# Check if the user has selected any text for additional context. #} {% if selected %} The user has the following text selected and may refer to it in their message: --- {{ selected }} --- {% endif %}  {# A list of files provided for context. The LLM should use these files as a reference. #} {% if files %} **Relevant Files:** The following files have been provided for context: {% for file in files %} - Name: {{ file.name }}   Contents: {{ file.file_contents }} {% endfor %} --- {% endif %}  {# Include the timestamp to provide temporal context for the query. #} {# This can be useful for time-sensitive questions. #} Timestamp: {{ timestamp }}",
      'agent_id': 'chat',
      'rag': null,
      'cag': null,
      'value_text': null,
      'html_content': null,
      'parent_agent_id': null,
    },
    {
      'id': '2',
      'input_schema': {
        'schema': 'http://json-schema.org/draft-07/schema#',
        'title': 'Architect LLM Input',
        'description': 'Schema for input to the Architect LLM for general chitchat and Q&A.',
        'long_description':
            'The Architect LLM is used for longer term task planning.  It is aimed at creating a long term step by step plan for a larger task.  It outputs an array of task descriptions.',
        'type': 'object',
        'properties': {
          'model': {
            'description': 'Model to use.',
            'type': 'string',
          },
          'user_id': {
            'description': 'Unique identifier for the user.',
            'type': 'string',
          },
          'query': {
            'description': "The user's freeform text query or message.",
            'type': 'string',
          },
          'session_id': {
            'description': 'Unique identifier for the current conversation session.',
            'type': 'string',
          },
          'timestamp': {
            'description': "Timestamp of the user's query in ISO 8601 format.",
            'type': 'string',
            'format': 'date-time',
          },
          'metadata': {},
          'files': {
            'description': 'An array of files to include in the context.',
            'type': 'array',
            'items': {
              'type': 'object',
              'properties': {
                'name': {
                  'description': 'The name of the file.',
                  'type': 'string',
                },
                'filepath': {
                  'description': 'The path to the file on the server.',
                  'type': 'string',
                },
              },
              'required': [
                'name',
                'filepath',
              ],
            },
          },
          'selected': {
            'description': 'Any text or code selected by the user for context',
            'type': 'string',
          },
        },
        'required': [
          'query',
          'user_id',
          'session_id',
          'timestamp',
          'metadata',
        ],
      },
      'output_schema': {
        'schema': 'http://json-schema.org/draft-07/schema#',
        'title': 'Chat LLM Output',
        'description': 'Schema for output to the Chat LLM for general chitchat and Q&A.',
        'type': 'object',
        'properties': {
          'name': {
            'description':
                'The name of the LLM. This should be a human-readable identifier for the agent responding. Its purpose is to clearly attribute the source of the response.',
            'type': 'string',
          },
          'response': {
            'description':
                "The LLM's text response to the user's query. This is a user-facing, conversational reply that should summarize the action taken and provide a high-level overview of the changes.",
            'type': 'string',
          },
        },
        'required': [
          'name',
          'response',
        ],
      },
      'jinja_template':
          "{# This Jinja template formats a JSON object matching the chat-IN.json schema #} {# into a clean, human-readable prompt for a Large Language Model (LLM). #} {# It prioritizes the user's query and any selected text for context, #} {# while omitting irrelevant metadata like user_id and session_id. #} You are an expert Jinja developer. {{ name }} Agent Role: Conversational Partner Purpose: You are to engage in a helpful dialogue with the user. Your task is to discuss project ideas, answer any questions they have, and provide clear and concise explanations and documentation especially pertaining to Jinja. You should be direct and responsive, acting as a knowledgeable guide throughout the project.  {# Display conversation history if available #} {%- if history -%} **Conversation History:** {%- for message in history -%} **{{ message.role | capitalize }}**: {% if message.role == 'assistant' %}{{- message.content.response }}{% else %}{{- message.content }}{% endif %} {%- endfor -%} --- {%- endif -%}  {# The main query from the user. #} {{ query }}  {# Check if the user has selected any text for additional context. #} {% if selected %} The user has the following text selected and may refer to it in their message: --- {{ selected }} --- {% endif %}  {# A list of files provided for context. The LLM should use these files as a reference. #} {% if files %} **Relevant Files:** The following files have been provided for context: {% for file in files %} - Name: {{ file.name }}   Contents: {{ file.file_contents }} {% endfor %} --- {% endif %}  {# Include the timestamp to provide temporal context for the query. #} {# This can be useful for time-sensitive questions. #} Timestamp: {{ timestamp }}",
      'agent_id': 'architect',
      'rag': null,
      'cag': null,
      'value_text': null,
      'html_content': null,
      'parent_agent_id': null,
    },
    {
      'id': '3',
      'input_schema': {
        'schema': 'http://json-schema.org/draft-07/schema#',
        'title': 'Archivist LLM Input',
        'description': 'Schema for input to the Archivist LLM for creating long term memories.',
        'long_description':
            "This is a very simple endpoint to just add to long-term memory.  It formulates the user's input (including optional files and selected text/code), for long term storage and returns a message on success.",
        'type': 'object',
        'properties': {
          'model': {
            'description': 'Model to use.',
            'type': 'string',
          },
          'agent_id': {
            'description': 'Unique identifier for the specific agent or role generating the response.',
            'type': 'string',
            'enum': [
              'solver',
              'proofreader',
              'chat',
              'vibe',
              'context',
              'spec',
            ],
          },
          'user_id': {
            'description': 'Unique identifier for the user.',
            'type': 'string',
          },
          'query': {
            'description': "The user's freeform text query or message.",
            'type': 'string',
          },
          'session_id': {
            'description': 'Unique identifier for the current conversation session.',
            'type': 'string',
          },
          'timestamp': {
            'description': "Timestamp of the user's query in ISO 8601 format.",
            'type': 'string',
            'format': 'date-time',
          },
          'metadata': {},
          'files': {
            'description': 'An array of files to include in the context.',
            'type': 'array',
            'items': {
              'type': 'object',
              'properties': {
                'name': {
                  'description': 'The name of the file.',
                  'type': 'string',
                },
                'filepath': {
                  'description': 'The path to the file on the server.',
                  'type': 'string',
                },
              },
              'required': [
                'name',
                'filepath',
              ],
            },
          },
          'selected': {
            'description': 'Any text or code selected by the user for context',
            'type': 'string',
          },
        },
        'required': [
          'query',
          'user_id',
          'session_id',
          'timestamp',
          'metadata',
        ],
      },
      'output_schema': {
        'schema': 'http://json-schema.org/draft-07/schema#',
        'title': 'Chat LLM Output',
        'description': 'Schema for output to the Chat LLM for general chitchat and Q&A.',
        'type': 'object',
        'properties': {
          'name': {
            'description':
                'The name of the LLM. This should be a human-readable identifier for the agent responding. Its purpose is to clearly attribute the source of the response.',
            'type': 'string',
          },
          'response': {
            'description':
                "The LLM's text response to the user's query. This is a user-facing, conversational reply that should summarize the action taken and provide a high-level overview of the changes.",
            'type': 'string',
          },
        },
        'required': [
          'name',
          'response',
        ],
      },
      'jinja_template':
          "{# This Jinja template formats a JSON object matching the chat-IN.json schema #} {# into a clean, human-readable prompt for a Large Language Model (LLM). #} {# It prioritizes the user's query and any selected text for context, #} {# while omitting irrelevant metadata like user_id and session_id. #} You are an expert Jinja developer. {{ name }} Agent Role: Conversational Partner Purpose: You are to engage in a helpful dialogue with the user. Your task is to discuss project ideas, answer any questions they have, and provide clear and concise explanations and documentation especially pertaining to Jinja. You should be direct and responsive, acting as a knowledgeable guide throughout the project.  {# Display conversation history if available #} {%- if history -%} **Conversation History:** {%- for message in history -%} **{{ message.role | capitalize }}**: {% if message.role == 'assistant' %}{{- message.content.response }}{% else %}{{- message.content }}{% endif %} {%- endfor -%} --- {%- endif -%}  {# The main query from the user. #} {{ query }}  {# Check if the user has selected any text for additional context. #} {% if selected %} The user has the following text selected and may refer to it in their message: --- {{ selected }} --- {% endif %}  {# A list of files provided for context. The LLM should use these files as a reference. #} {% if files %} **Relevant Files:** The following files have been provided for context: {% for file in files %} - Name: {{ file.name }}   Contents: {{ file.file_contents }} {% endfor %} --- {% endif %}  {# Include the timestamp to provide temporal context for the query. #} {# This can be useful for time-sensitive questions. #} Timestamp: {{ timestamp }}",
      'agent_id': 'archivist',
      'rag': null,
      'cag': null,
      'value_text': null,
      'html_content': null,
      'parent_agent_id': null,
    },
    {
      'id': '4',
      'input_schema': {
        'schema': 'http://json-schema.org/draft-07/schema#',
        'title': 'Artist LLM Input',
        'description': 'Schema for input to the Artist LLM for generating color palettes.',
        'long_description':
            'The Artist LLM generates color palettes based on user queries. It can optionally take an existing color palette as context to modify.',
        'type': 'object',
        'properties': {
          'model': {
            'description': 'Model to use.',
            'type': 'string',
          },
          'agent_id': {
            'description': 'Unique identifier for the specific agent or role generating the response.',
            'type': 'string',
          },
          'user_id': {
            'description': 'Unique identifier for the user.',
            'type': 'string',
          },
          'query': {
            'description': "The user's freeform text query or message.",
            'type': 'string',
          },
          'session_id': {
            'description': 'Unique identifier for the current conversation session.',
            'type': 'string',
          },
          'timestamp': {
            'description': "Timestamp of the user's query in ISO 8601 format.",
            'type': 'string',
            'format': 'date-time',
          },
          'metadata': {
            'description': 'An open-ended object for any additional metadata.',
            'type': 'object',
          },
          'selected': {
            'description': 'Any text or code selected by the user for context',
            'type': 'string',
          },
          'task_id': {
            'description': 'The task from the Architect to work on',
            'type': 'string',
          },
          'color_palette': {
            'description': 'An optional array representing the current color palette, loaded from color_palette.json.',
            'type': 'array',
            'items': {
              'type': 'object',
            },
          },
          'history': {
            'description': 'A list of color updates.',
            'type': 'array',
            'items': {
              'type': 'object',
              'properties': {
                'agent': {
                  'description': "The user's message.",
                  'type': 'string',
                },
                'user': {
                  'description': "The agent's message",
                  'type': 'string',
                },
              },
              'required': [
                'agent',
                'user',
              ],
            },
          },
        },
        'required': [
          'query',
          'user_id',
          'session_id',
          'timestamp',
          'metadata',
        ],
      },
      'output_schema': {
        'schema': 'http://json-schema.org/draft-07/schema#',
        'title': 'Artist LLM Output',
        'description': "Schema for the Artist LLM's color palette generation.",
        'type': 'object',
        'properties': {
          'name': {
            'description': 'The name of the agent responding.',
            'type': 'string',
          },
          'response': {
            'description': 'A user-facing, conversational reply.',
            'type': 'string',
          },
          'edits': {
            'description': 'A list of color updates.',
            'type': 'array',
            'items': {
              'type': 'object',
              'properties': {
                'widget_id': {
                  'description': 'The ID of the UI widget to apply the color to.',
                  'type': 'string',
                  'enum': [
                    'primary',
                    'primaryforeground',
                    'primaryhover',
                    'secondary',
                    'secondaryforeground',
                    'tertiary',
                    'tertiaryforeground',
                    'accent',
                    'accentforeground',
                    'success',
                    'error',
                    'warning',
                    'info',
                    'textprimary',
                    'textsecondary',
                    'muted',
                    'mutedforeground',
                    'background',
                    'border',
                    'input',
                    'ring',
                    'card',
                    'cardforeground',
                    'popover',
                    'popoverforeground',
                  ],
                },
                'dark': {
                  'description': 'The hex color code for the widget in dark mode.',
                  'type': 'string',
                  'pattern': '^#[0-9a-fA-F]+',
                },
                'light': {
                  'description': 'The hex color code for the widget in light mode.',
                  'type': 'string',
                  'pattern': '^#[0-9a-fA-F]+',
                },
              },
              'required': [
                'widget_id',
                'dark',
                'light',
              ],
            },
          },
        },
        'required': [
          'name',
          'response',
          'edits',
        ],
      },
      'jinja_template':
          "{# This Jinja template formats a JSON object matching the artist-IN.json schema #} {# into a detailed prompt for the Artist LLM. #} You are an expert color theorist and designer. {{ name }} Agent Role: Color Palette Generator Purpose: You are responsible for generating a color palette based on the user's request. Your output must be a single JSON object.  Do not make the dark themes too dark or the light themes too light. When making a dark theme ensure that the background is not pure black, it should still have a slight tint of some color the user asks for.  {# Display conversation history if available #} {% if history %} **Conversation History:** {% for message in history %} You: {{- message.content.agent }} Me: {{- message.content.user }} {% endif %} {% endfor %} --- {% endif %}  **Available Colors Schema for `edits`:** You can only change colors that are defined in the following schema. You must use the `widget_id` from this schema.  - primary  - primaryforeground  - primaryhover  - secondary  - secondaryforeground  - tertiary  - tertiaryforeground  - accent  - accentforeground  - success  - error  - warning  - info  - textprimary  - textsecondary  - muted  - mutedforeground  - background  - border  - input  - ring  - card  - cardforeground  - popover  - popoverforeground  {% if color_palette %} **Current Color Palette:** Here is the existing color palette. Use this as a baseline for your changes. {% for widget in color_palette %} - **{{ widget.widget_id }}**:   {% for prop in widget.properties %}   - `{{ prop.property_id }}`: `{{ prop.value }}`   {% endfor %} {% endfor %} {% endif %}  **User Request:** {{ query }}  Timestamp: {{ timestamp }}  --- Based on the user's request, generate the complete JSON output now. Do not include any other text or explanation.",
      'agent_id': 'artist',
      'rag': null,
      'cag': null,
      'value_text': null,
      'html_content': null,
      'parent_agent_id': null,
    },
    {
      'id': '5',
      'input_schema': {
        'schema': 'http://json-schema.org/draft-07/schema#',
        'title': 'Builder LLM Input',
        'description': 'Schema for input the Builder LLM for quick vibe coding',
        'long_description':
            'The Builder LLM is used for rapid development and vibe coding.  It will take in a user request, and respond with an array of proposed changes and explanations for each.  The Builder is used to carry out the plans of the Architect',
        'type': 'object',
        'properties': {
          'model': {
            'description': 'Model to use.',
            'type': 'string',
          },
          'agent_id': {
            'description': 'Unique identifier for the specific agent or role generating the response.',
            'type': 'string',
            'enum': [
              'solver',
              'proofreader',
              'chat',
              'vibe',
              'context',
              'spec',
            ],
          },
          'user_id': {
            'description': 'Unique identifier for the user.',
            'type': 'string',
          },
          'query': {
            'description': "The user's freeform text query or message.",
            'type': 'string',
          },
          'session_id': {
            'description': 'Unique identifier for the current conversation session.',
            'type': 'string',
          },
          'timestamp': {
            'description': "Timestamp of the user's query in ISO 8601 format.",
            'type': 'string',
            'format': 'date-time',
          },
          'metadata': {},
          'files': {
            'description': 'An array of files to include in the context.',
            'type': 'array',
            'items': {
              'type': 'object',
              'properties': {
                'name': {
                  'description': 'The name of the file.',
                  'type': 'string',
                },
                'filepath': {
                  'description': 'The path to the file on the server.',
                  'type': 'string',
                },
              },
              'required': [
                'name',
                'filepath',
              ],
            },
          },
          'selected': {
            'description': 'Any text or code selected by the user for context',
            'type': 'string',
          },
          'task_id': {
            'description': 'The task from the Architect to work on',
            'type': 'string',
          },
        },
        'required': [
          'query',
          'user_id',
          'session_id',
          'timestamp',
          'metadata',
          'files',
        ],
      },
      'output_schema': {
        'schema': 'http://json-schema.org/draft-07/schema#',
        'title': 'Chat LLM Output',
        'description': 'Schema for output to the Chat LLM for general chitchat and Q&A.',
        'type': 'object',
        'properties': {
          'name': {
            'description':
                'The name of the LLM. This should be a human-readable identifier for the agent responding. Its purpose is to clearly attribute the source of the response.',
            'type': 'string',
          },
          'response': {
            'description':
                "The LLM's text response to the user's query. This is a user-facing, conversational reply that should summarize the action taken and provide a high-level overview of the changes.",
            'type': 'string',
          },
        },
        'required': [
          'name',
          'response',
        ],
      },
      'jinja_template':
          "{# This Jinja template formats a JSON object matching the chat-IN.json schema #} {# into a clean, human-readable prompt for a Large Language Model (LLM). #} {# It prioritizes the user's query and any selected text for context, #} {# while omitting irrelevant metadata like user_id and session_id. #} You are an expert Jinja developer. {{ name }} Agent Role: Conversational Partner Purpose: You are to engage in a helpful dialogue with the user. Your task is to discuss project ideas, answer any questions they have, and provide clear and concise explanations and documentation especially pertaining to Jinja. You should be direct and responsive, acting as a knowledgeable guide throughout the project.  {# Display conversation history if available #} {%- if history -%} **Conversation History:** {%- for message in history -%} **{{ message.role | capitalize }}**: {% if message.role == 'assistant' %}{{- message.content.response }}{% else %}{{- message.content }}{% endif %} {%- endfor -%} --- {%- endif -%}  {# The main query from the user. #} {{ query }}  {# Check if the user has selected any text for additional context. #} {% if selected %} The user has the following text selected and may refer to it in their message: --- {{ selected }} --- {% endif %}  {# A list of files provided for context. The LLM should use these files as a reference. #} {% if files %} **Relevant Files:** The following files have been provided for context: {% for file in files %} - Name: {{ file.name }}   Contents: {{ file.file_contents }} {% endfor %} --- {% endif %}  {# Include the timestamp to provide temporal context for the query. #} {# This can be useful for time-sensitive questions. #} Timestamp: {{ timestamp }}",
      'agent_id': 'builder',
      'rag': null,
      'cag': null,
      'value_text': null,
      'html_content': null,
      'parent_agent_id': null,
    },
    {
      'id': '6',
      'input_schema': {
        'schema': 'http://json-schema.org/draft-07/schema#',
        'title': 'Archivist LLM Input',
        'description': 'Schema for input to the Archivist LLM for creating long term memories.',
        'long_description':
            "This is a very simple endpoint to just add to long-term memory.  It formulates the user's input (including optional files and selected text/code), for long term storage and returns a message on success.",
        'type': 'object',
        'properties': {
          'model': {
            'description': 'Model to use.',
            'type': 'string',
          },
          'agent_id': {
            'description': 'Unique identifier for the specific agent or role generating the response.',
            'type': 'string',
            'enum': [
              'solver',
              'proofreader',
              'chat',
              'vibe',
              'context',
              'spec',
            ],
          },
          'user_id': {
            'description': 'Unique identifier for the user.',
            'type': 'string',
          },
          'query': {
            'description': "The user's freeform text query or message.",
            'type': 'string',
          },
          'session_id': {
            'description': 'Unique identifier for the current conversation session.',
            'type': 'string',
          },
          'timestamp': {
            'description': "Timestamp of the user's query in ISO 8601 format.",
            'type': 'string',
            'format': 'date-time',
          },
          'metadata': {
            'description': 'An open-ended object for any additional metadata.',
            'type': 'object',
          },
          'files': {
            'description': 'An array of files to include in the context.',
            'type': 'array',
            'items': {
              'type': 'object',
              'properties': {
                'name': {
                  'description':
                      "The name of the LLM. This should be a human-readable identifier for the agent responding, for example, 'Vibe Agent'. Its purpose is to clearly attribute the source of the response.",
                  'type': 'string',
                },
                'filepath': {
                  'description': 'The path to the file on the server.',
                  'type': 'string',
                },
                'file_contents': {
                  'description': 'The contents of the file',
                  'type': 'string',
                },
              },
              'required': [
                'name',
                'filepath',
                'file_contents',
              ],
            },
          },
          'selected': {
            'description': 'Any text or code selected by the user for context',
            'type': 'string',
          },
          'history': {
            'description': 'A list of color updates.',
            'type': 'array',
            'items': {
              'type': 'object',
              'properties': {
                'agent': {
                  'description': "The user's message.",
                  'type': 'string',
                },
                'user': {
                  'description': "The agent's message",
                  'type': 'string',
                },
              },
              'required': [
                'agent',
                'user',
              ],
            },
          },
        },
        'required': [
          'query',
          'user_id',
          'session_id',
          'timestamp',
          'metadata',
        ],
      },
      'output_schema': {
        'schema': 'http://json-schema.org/draft-07/schema#',
        'title': 'Archivist LLM Output',
        'description': 'Schema for output from the Archivist LLM for creating long term memories.',
        'long_description':
            "This is a very simple endpoint to just add to long-term memory.  It formulates the user's input (including optional files and selected text/code), for long term storage and returns a message on success.",
        'type': 'object',
        'properties': {
          'name': {
            'description':
                'The name of the LLM. This should be a human-readable identifier for the agent responding. Its purpose is to clearly attribute the source of the response.',
            'type': 'string',
          },
          'response': {
            'description':
                "The LLM's text response to the user's query. This is a user-facing, conversational reply that should summarize the action taken and provide a high-level overview of the changes.",
            'type': 'string',
          },
        },
        'required': [
          'name',
          'response',
        ],
      },
      'jinja_template':
          "{# This Jinja template formats a JSON object matching the context-IN.json schema #} {# into a structured prompt for the Archivist LLM, which is responsible for creating long-term memories. #} {# The template captures the user's query, any selected text, and associated files to form a comprehensive memory. #} {# It excludes transient data like user_id and session_id. #} You are an expert Jinja developer. {{ name }} Agent Role: Data Pre-processor Purpose: Your primary job is to efficiently scan incoming, unstructured data and extract the most relevant information. You should then reformat this data into a structured and easily digestible format for other LLMs and for long-term memory. You must identify key entities, relationships, and concepts, and present them in a clear, organized way. The user will be able to individually reject or accept each of your edits so do not be timid, as long as they are small and digestible.  {# Display conversation history if available #} {% if history %} **Conversation History:** {% for message in history %} You: {{- message.content.agent }} Me: {{- message.content.user }} {% endif %} {% endfor %} --- {% endif %}  {# The core text or query from the user that needs to be remembered. #} {{ query }}  {# If the user had text selected, include it as part of the memory's context. #} {% if selected %} The user had the following text selected: --- {{ selected }} --- {% endif %}  {# If files were associated with this memory, list them. #} {% if files %} **Relevant Files:** The following files have been provided for context: {% for file in files %} - Name: {{ file.name }}   Contents: {{ file.file_contents }} {% endfor %} --- {% endif %}  {# Include the timestamp to record when this memory was created. #} Timestamp: {{ timestamp }}",
      'agent_id': 'context',
      'rag': null,
      'cag': null,
      'value_text': null,
      'html_content': null,
      'parent_agent_id': null,
    },
    {
      'id': '7',
      'input_schema': {
        'schema': 'http://json-schema.org/draft-07/schema#',
        'title': 'Debugger LLM Input',
        'description': 'Schema for input to the Debugger LLM for general chitchat and Q&A.',
        'long_description':
            'The Debugger LLM is the most complex.  It takes in files, selected code/text, and a unique bug_id.  The bug_id will be needed to track harder bugs that require multiple sessions to resolve.  Bugs will be added to a database.  It will return optional edits, like the Builder.  More significantly it will return a list of hypotheses and attempts which it will use to reason, problem solve, and most importantly prevent backtracking.',
        'type': 'object',
        'properties': {
          'model': {
            'description': 'Model to use.',
            'type': 'string',
          },
          'user_id': {
            'description': 'Unique identifier for the user.',
            'type': 'string',
          },
          'query': {
            'description': "The user's freeform text query or message.",
            'type': 'string',
          },
          'session_id': {
            'description': 'Unique identifier for the current conversation session.',
            'type': 'string',
          },
          'timestamp': {
            'description': "Timestamp of the user's query in ISO 8601 format.",
            'type': 'string',
            'format': 'date-time',
          },
          'metadata': {},
          'bug_id': {
            'description': 'The unique identifier for the bug.',
            'type': 'string',
          },
          'files': {
            'description': 'An array of files to include in the context.',
            'type': 'array',
            'items': {
              'type': 'object',
              'properties': {
                'name': {
                  'description': 'The name of the file.',
                  'type': 'string',
                },
                'filepath': {
                  'description': 'The path to the file on the server.',
                  'type': 'string',
                },
              },
              'required': [
                'name',
                'filepath',
              ],
            },
          },
          'selected': {
            'description': 'Any text or code selected by the user for context',
            'type': 'string',
          },
        },
        'required': [
          'query',
          'user_id',
          'session_id',
          'timestamp',
          'metadata',
          'bug_id',
        ],
      },
      'output_schema': {
        'schema': 'http://json-schema.org/draft-07/schema#',
        'title': 'Chat LLM Output',
        'description': 'Schema for output to the Chat LLM for general chitchat and Q&A.',
        'type': 'object',
        'properties': {
          'name': {
            'description':
                'The name of the LLM. This should be a human-readable identifier for the agent responding. Its purpose is to clearly attribute the source of the response.',
            'type': 'string',
          },
          'response': {
            'description':
                "The LLM's text response to the user's query. This is a user-facing, conversational reply that should summarize the action taken and provide a high-level overview of the changes.",
            'type': 'string',
          },
        },
        'required': [
          'name',
          'response',
        ],
      },
      'jinja_template':
          "\"\"\"{# This Jinja template formats a JSON object matching the chat-IN.json schema #} {# into a clean, human-readable prompt for a Large Language Model (LLM). #} {# It prioritizes the user's query and any selected text for context, #} {# while omitting irrelevant metadata like user_id and session_id. #} You are an expert Jinja developer. {{ name }} Agent Role: Conversational Partner Purpose: You are to engage in a helpful dialogue with the user. Your task is to discuss project ideas, answer any questions they have, and provide clear and concise explanations and documentation especially pertaining to Jinja. You should be direct and responsive, acting as a knowledgeable guide throughout the project.  {# Display conversation history if available #} {%- if history -%} **Conversation History:** {%- for message in history -%} **{{ message.role | capitalize }}**: {% if message.role == 'assistant' %}{{- message.content.response }}{% else %}{{- message.content }}{% endif %} {%- endfor -%} --- {%- endif -%}  {# The main query from the user. #} {{ query }}  {# Check if the user has selected any text for additional context. #} {% if selected %} The user has the following text selected and may refer to it in their message: --- {{ selected }} --- {% endif %}  {# A list of files provided for context. The LLM should use these files as a reference. #} {% if files %} **Relevant Files:** The following files have been provided for context: {% for file in files %} - Name: {{ file.name }}   Contents: {{ file.file_contents }} {% endfor %} --- {% endif %}  {# Include the timestamp to provide temporal context for the query. #} {# This can be useful for time-sensitive questions. #} Timestamp: {{ timestamp }} \"\"\"",
      'agent_id': 'debugger',
      'rag': null,
      'cag': null,
      'value_text': null,
      'html_content': null,
      'parent_agent_id': null,
    },
    {
      'id': '8',
      'input_schema': {
        'schema': 'http://json-schema.org/draft-07/schema#',
        'title': 'Chat LLM Input',
        'description': 'Schema for input to the Chat LLM for general chitchat and Q&A.',
        'type': 'object',
        'properties': {
          'model': {
            'description': 'Model to use.',
            'type': 'string',
          },
          'image': {
            'description': 'Image url',
            'type': 'string',
          },
        },
        'required': [
          'model',
          'image',
        ],
      },
      'output_schema': {
        'schema': 'http://json-schema.org/draft-07/schema#',
        'title': 'Chat LLM Output',
        'description': 'Schema for output to the Chat LLM for general chitchat and Q&A.',
        'type': 'object',
        'properties': {
          'name': {
            'description':
                'The name of the LLM. This should be a human-readable identifier for the agent responding. Its purpose is to clearly attribute the source of the response.',
            'type': 'string',
          },
          'response': {
            'description':
                "The LLM's text response to the user's query. This is a user-facing, conversational reply that should summarize the action taken and provide a high-level overview of the changes.",
            'type': 'string',
          },
        },
        'required': [
          'name',
          'response',
        ],
      },
      'jinja_template':
          "{# This Jinja template formats a JSON object matching the chat-IN.json schema #} {# into a clean, human-readable prompt for a Large Language Model (LLM). #} {# It prioritizes the user's query and any selected text for context, #} {# while omitting irrelevant metadata like user_id and session_id. #} You are an expert Jinja developer. {{ name }} Agent Role: Conversational Partner Purpose: You are to engage in a helpful dialogue with the user. Your task is to discuss project ideas, answer any questions they have, and provide clear and concise explanations and documentation especially pertaining to Jinja. You should be direct and responsive, acting as a knowledgeable guide throughout the project.  {# Display conversation history if available #} {%- if history -%} **Conversation History:** {%- for message in history -%} **{{ message.role | capitalize }}**: {% if message.role == 'assistant' %}{{- message.content.response }}{% else %}{{- message.content }}{% endif %} {%- endfor -%} --- {%- endif -%}  {# The main query from the user. #} {{ query }}  {# Check if the user has selected any text for additional context. #} {% if selected %} The user has the following text selected and may refer to it in their message: --- {{ selected }} --- {% endif %}  {# A list of files provided for context. The LLM should use these files as a reference. #} {% if files %} **Relevant Files:** The following files have been provided for context: {% for file in files %} - Name: {{ file.name }}   Contents: {{ file.file_contents }} {% endfor %} --- {% endif %}  {# Include the timestamp to provide temporal context for the query. #} {# This can be useful for time-sensitive questions. #} Timestamp: {{ timestamp }}",
      'agent_id': 'photographer',
      'rag': null,
      'cag': null,
      'value_text': null,
      'html_content': null,
      'parent_agent_id': null,
    },
    {
      'id': '9',
      'input_schema': {
        'schema': 'http://json-schema.org/draft-07/schema#',
        'title': 'Proofreader LLM Input',
        'description': 'Schema for input to the Proofreader LLM for code review',
        'long_description':
            'The Proofreader LLM is used as a simpler form of the Builder.  It implicitly will always examine only the currently open file, and try to suggest more minimal, best-practice and stylistic changes.',
        'type': 'object',
        'properties': {
          'model': {
            'description': 'Model to use.',
            'type': 'string',
          },
          'agent_id': {
            'description': 'Unique identifier for the specific agent or role generating the response.',
            'type': 'string',
            'enum': [
              'solver',
              'proofreader',
              'chat',
              'vibe',
              'context',
              'spec',
            ],
          },
          'user_id': {
            'description': 'Unique identifier for the user.',
            'type': 'string',
          },
          'session_id': {
            'description': 'Unique identifier for the current conversation session.',
            'type': 'string',
          },
          'timestamp': {
            'description': "Timestamp of the user's query in ISO 8601 format.",
            'type': 'string',
            'format': 'date-time',
          },
          'file': {
            'name': {
              'description': 'The name of the file.',
              'type': 'string',
            },
            'filepath': {
              'description': 'The path to the file on the server.',
              'type': 'string',
            },
          },
          'selected': {
            'description': 'Any text or code selected by the user for context',
            'type': 'string',
          },
          'history': {
            'description': 'A list of color updates.',
            'type': 'array',
            'items': {
              'type': 'object',
              'properties': {
                'agent': {
                  'description': "The user's message.",
                  'type': 'string',
                },
                'user': {
                  'description': "The agent's message",
                  'type': 'string',
                },
              },
              'required': [
                'agent',
                'user',
              ],
            },
          },
        },
        'required': [
          'user_id',
          'session_id',
          'timestamp',
          'model',
          'agent_id',
        ],
      },
      'output_schema': {
        'schema': 'http://json-schema.org/draft-07/schema#',
        'title': 'Proofreader LLM Output',
        'description': 'Schema for output to the Proofreader LLM for code review',
        'long_description':
            'The Proofreader LLM is used as a simpler form of the Builder.  It implicitly will always examine only the currently open file, and try to suggest more minimal, best-practice and stylistic changes.',
        'type': 'object',
        'properties': {
          'response': {
            'description': "The LLM's text response to the user's query.",
            'type': 'string',
          },
          'edits': {
            'description': 'A list of objects detailing edits made to files.',
            'type': 'array',
            'items': {
              'type': 'object',
              'properties': {
                'edit_id': {
                  'type': 'string',
                  'description': 'Unique identifier for the edit',
                },
                'file_path': {
                  'type': 'string',
                  'description': 'The path to the file where the replacement occurred.',
                },
                'old_string': {
                  'type': 'string',
                  'description': 'The string that was replaced.',
                },
                'new_string': {
                  'type': 'string',
                  'description': 'The string that replaced the old string.',
                },
                'justification': {
                  'type': 'string',
                  'description': 'An explanation of the decision.',
                },
              },
              'required': [
                'edit_id',
                'file_path',
                'old_string',
                'new_string',
              ],
            },
          },
        },
        'required': [
          'response',
          'edits',
        ],
      },
      'jinja_template':
          '{# This Jinja template formats a JSON object matching the proofreader-IN.json schema #} {# into a prompt for the Proofreader LLM, which specializes in code review. #} {# The prompt is designed to be concise, focusing on the file to be reviewed and any selected text. #} {# It omits irrelevant metadata like user_id and session_id. #} You are an expert Jinja developer. {{ name }} Agent Role: Code Reviewer Purpose: Your job is to perform a detailed code review on the selected files. You will read through the code and make minimal, non-structural changes. Your goal is to simplify the code, ensure it adheres to best practices, and improve formatting for best practices without altering its core functionality. The user will be able to individually reject or accept each of your edits so do not be timid, as long as they are small and digestible.  {# Display conversation history if available #} {% if history %} **Conversation History:** {% for message in history %} You: {{- message.content.agent }} Me: {{- message.content.user }} {% endif %} {% endfor %} --- {% endif %}  Please review the following file for style, best practices, and potential improvements.  {% if files %} **Relevant Files:** The following files have been provided for context: {% for file in files %} - Name: {{ file.name }}   Contents: {{ file.file_contents }} {% endfor %} --- {% endif %}  {% if selected %} The user has highlighted the following section for specific attention: --- {{ selected }} --- {% endif %}  {# The timestamp provides context for when the review was requested. #} Timestamp: {{ timestamp }}',
      'agent_id': 'proofreader',
      'rag': null,
      'cag': null,
      'value_text': null,
      'html_content': null,
      'parent_agent_id': null,
    },
    {
      'id': '10',
      'input_schema': {
        'schema': 'http://json-schema.org/draft-07/schema#',
        'title': 'Secretary LLM Input',
        'description': 'Schema for input to the Secretary LLM for general chitchat and Q&A.',
        'type': 'object',
        'properties': {
          'model': {
            'description': 'Model to use.',
            'type': 'string',
          },
          'agent_id': {
            'description': 'Unique identifier for the specific agent or role generating the response.',
            'type': 'string',
            'enum': [
              'solver',
              'proofreader',
              'chat',
              'vibe',
              'context',
              'spec',
            ],
          },
          'user_id': {
            'description': 'Unique identifier for the user.',
            'type': 'string',
          },
          'query': {
            'description': "The user's freeform text query or message.",
            'type': 'string',
          },
          'session_id': {
            'description': 'Unique identifier for the current conversation session.',
            'type': 'string',
          },
          'timestamp': {
            'description': "Timestamp of the user's query in ISO 8601 format.",
            'type': 'string',
            'format': 'date-time',
          },
          'metadata': {},
          'selected': {
            'description': 'Any text or code selected by the user for context',
            'type': 'string',
          },
        },
        'required': [
          'query',
          'user_id',
          'session_id',
          'timestamp',
          'metadata',
        ],
      },
      'output_schema': {
        'schema': 'http://json-schema.org/draft-07/schema#',
        'title': 'Chat LLM Output',
        'description': 'Schema for output to the Chat LLM for general chitchat and Q&A.',
        'type': 'object',
        'properties': {
          'name': {
            'description':
                'The name of the LLM. This should be a human-readable identifier for the agent responding. Its purpose is to clearly attribute the source of the response.',
            'type': 'string',
          },
          'response': {
            'description':
                "The LLM's text response to the user's query. This is a user-facing, conversational reply that should summarize the action taken and provide a high-level overview of the changes.",
            'type': 'string',
          },
        },
        'required': [
          'name',
          'response',
        ],
      },
      'jinja_template':
          "{# This Jinja template formats a JSON object matching the chat-IN.json schema #} {# into a clean, human-readable prompt for a Large Language Model (LLM). #} {# It prioritizes the user's query and any selected text for context, #} {# while omitting irrelevant metadata like user_id and session_id. #} You are an expert Jinja developer. {{ name }} Agent Role: Conversational Partner Purpose: You are to engage in a helpful dialogue with the user. Your task is to discuss project ideas, answer any questions they have, and provide clear and concise explanations and documentation especially pertaining to Jinja. You should be direct and responsive, acting as a knowledgeable guide throughout the project.  {# Display conversation history if available #} {%- if history -%} **Conversation History:** {%- for message in history -%} **{{ message.role | capitalize }}**: {% if message.role == 'assistant' %}{{- message.content.response }}{% else %}{{- message.content }}{% endif %} {%- endfor -%} --- {%- endif -%}  {# The main query from the user. #} {{ query }}  {# Check if the user has selected any text for additional context. #} {% if selected %} The user has the following text selected and may refer to it in their message: --- {{ selected }} --- {% endif %}  {# A list of files provided for context. The LLM should use these files as a reference. #} {% if files %} **Relevant Files:** The following files have been provided for context: {% for file in files %} - Name: {{ file.name }}   Contents: {{ file.file_contents }} {% endfor %} --- {% endif %}  {# Include the timestamp to provide temporal context for the query. #} {# This can be useful for time-sensitive questions. #} Timestamp: {{ timestamp }}",
      'agent_id': 'secretary',
      'rag': null,
      'cag': null,
      'value_text': null,
      'html_content': null,
      'parent_agent_id': null,
    },
    {
      'id': '11',
      'input_schema': {
        'schema': 'http://json-schema.org/draft-07/schema#',
        'title': 'Solver LLM Input',
        'description': 'Schema for input to the Solver LLM for general chitchat and Q&A.',
        'long_description':
            'The Solver LLM is the most complex.  It takes in files, selected code/text, and a unique bug_id.  The bug_id will be needed to track harder bugs that require multiple sessions to resolve.  Bugs will be added to a database.  It will return optional edits, like the Builder.  More significantly it will return a list of hypotheses and attempts which it will use to reason, problem solve, and most importantly prevent backtracking.',
        'type': 'object',
        'properties': {
          'model': {
            'description': 'Model to use.',
            'type': 'string',
          },
          'agent_id': {
            'description': 'Unique identifier for the specific agent or role generating the response.',
            'type': 'string',
            'enum': [
              'solver',
              'proofreader',
              'chat',
              'vibe',
              'context',
              'spec',
            ],
          },
          'user_id': {
            'description': 'Unique identifier for the user.',
            'type': 'string',
          },
          'query': {
            'description': "The user's freeform text query or message.",
            'type': 'string',
          },
          'error_messages': {
            'description': 'An array of relevant error messages.',
            'type': 'array',
            'items': {
              'type': 'object',
              'properties': {
                'text': {
                  'description': 'The text of the error message.',
                  'type': 'string',
                },
                'source': {
                  'description': 'The program and file which triggered the error',
                  'type': 'string',
                },
              },
              'required': [
                'text',
                'source',
              ],
            },
          },
          'session_id': {
            'description': 'Unique identifier for the current conversation session.',
            'type': 'string',
          },
          'timestamp': {
            'description': "Timestamp of the user's query in ISO 8601 format.",
            'type': 'string',
            'format': 'date-time',
          },
          'metadata': {
            'description': 'An open-ended object for any additional metadata.',
            'type': 'object',
          },
          'bug_id': {
            'description': 'The unique identifier for the bug.',
            'type': 'string',
          },
          'files': {
            'description': 'An array of files to include in the context.',
            'type': 'array',
            'items': {
              'type': 'object',
              'properties': {
                'name': {
                  'description':
                      "The name of the LLM. This should be a human-readable identifier for the agent responding, for example, 'Vibe Agent'. Its purpose is to clearly attribute the source of the response.",
                  'type': 'string',
                },
                'filepath': {
                  'description': 'The path to the file on the server.',
                  'type': 'string',
                },
                'file_contents': {
                  'description': 'The contents of the file',
                  'type': 'string',
                },
              },
              'required': [
                'name',
                'filepath',
                'file_contents',
              ],
            },
          },
          'selected': {
            'description': 'Any text or code selected by the user for context',
            'type': 'string',
          },
          'history': {
            'description': 'A list of color updates.',
            'type': 'array',
            'items': {
              'type': 'object',
              'properties': {
                'agent': {
                  'description': "The user's message.",
                  'type': 'string',
                },
                'user': {
                  'description': "The agent's message",
                  'type': 'string',
                },
              },
              'required': [
                'agent',
                'user',
              ],
            },
          },
        },
        'required': [
          'query',
          'user_id',
          'session_id',
          'timestamp',
          'metadata',
          'bug_id',
        ],
      },
      'output_schema': {
        'schema': 'http://json-schema.org/draft-07/schema#',
        'title': 'Solver LLM Output',
        'description': 'Schema for output to the Solver LLM for general chitchat and Q&A.',
        'long_description':
            'The Solver LLM is the most complex.  It takes in files, selected code/text, and a unique bug_id.  The bug_id will be needed to track harder bugs that require multiple sessions to resolve.  Bugs will be added to a database.  It will return optional edits, like the Builder.  More significantly it will return a list of hypotheses and attempts which it will use to reason, problem solve, and most importantly prevent backtracking.',
        'type': 'object',
        'properties': {
          'name': {
            'description':
                'The name of the LLM. This should be a human-readable identifier for the agent responding. Its purpose is to clearly attribute the source of the response.',
            'type': 'string',
          },
          'response': {
            'description':
                "The LLM's text response to the user's query. This is a user-facing, conversational reply that should summarize the action taken and provide a high-level overview of the changes.",
            'type': 'string',
          },
          'edits': {
            'description':
                'A list of objects detailing edits made to files. This array contains machine-readable instructions for applying changes to the codebase, allowing for automated file modifications.',
            'type': 'array',
            'items': {
              'type': 'object',
              'properties': {
                'file_path': {
                  'type': 'string',
                  'description':
                      'The full, absolute path to the file where the replacement occurred. This must be an exact path to ensure the correct file is targeted for modification.',
                },
                'old_string': {
                  'type': 'string',
                  'description':
                      'The exact, literal string that was replaced. To ensure a successful patch, this must match the target text precisely, including all whitespace, indentation, and newlines.',
                },
                'new_string': {
                  'type': 'string',
                  'description':
                      'The exact, literal string that replaced the old string. This is the new content that will be written into the file.',
                },
                'justification': {
                  'type': 'string',
                  'description':
                      "A developer-facing explanation of the decision. This field should clarify why the change was made, linking it back to the original user request or the agent's reasoning process.",
                },
              },
              'required': [
                'file_path',
                'old_string',
                'new_string',
              ],
            },
          },
          'hypotheses': {
            'description': "A list of hypotheses for the bug's cause that have failed.",
            'type': 'array',
            'items': {
              'type': 'object',
              'properties': {
                'description': {
                  'type': 'string',
                  'description': 'The description of the attempt.',
                },
                'success': {
                  'type': [
                    'boolean',
                    'null',
                  ],
                  'description': 'If it was shown true or false.  If it is null, it has not been verified either way.',
                },
              },
              'required': [
                'description',
                'success',
              ],
            },
          },
          'attempts': {
            'description': 'A list of attempts to fix the bug that have failed.',
            'type': 'array',
            'items': {
              'type': 'object',
              'properties': {
                'attempt_id': {
                  'type': 'string',
                  'description': 'Unique identifier for the attempt',
                },
                'edits': {
                  'description':
                      'A list of objects detailing edits made to files. This array contains machine-readable instructions for applying changes to the codebase, allowing for automated file modifications.',
                  'type': 'array',
                  'items': {
                    'type': 'object',
                    'properties': {
                      'edit_id': {
                        'type': 'string',
                        'description':
                            'A unique identifier for the edit, used for tracking and logging purposes. This can be a timestamp, a hash, or any other unique string.',
                      },
                    },
                    'required': [
                      'edit_id',
                    ],
                  },
                },
                'description': {
                  'type': 'string',
                  'description': 'The description of the attempt.',
                },
              },
              'required': [
                'description',
              ],
            },
          },
        },
        'required': [
          'name',
          'response',
        ],
      },
      'jinja_template':
          "{# This Jinja template formats a JSON object matching the solver-IN.json schema #} {# into a comprehensive prompt for the Solver LLM. The Solver LLM is designed for complex bug resolution. #} {# This prompt provides all necessary context for the LLM to diagnose, hypothesize, and propose solutions. #} {# It emphasizes tracking the bug via a bug_id and systematically listing all relevant information. #} {# Transient metadata like user_id and session_id are omitted to keep the prompt focused. #} You are an expert Jinja developer. {{ name }} Agent Role: Debugging Specialist Purpose: You are a highly advanced problem-solver. Your job is to diagnose and fix complex programming problems. You will be provided with extensive information, including debug logs, error messages, and relevant source code. You must analyze this data to pinpoint the root cause of the problem and provide a comprehensive solution and explanation. Move slowly and methodically and create alternative hypotheses at each step, testing and disproving them carefully to diagnose the problem. Your task is to analyze the following bug report, generate hypotheses, and propose solutions. You must track your reasoning and attempts to avoid backtracking. The user will be able to individually reject or accept each of your edits so do not be timid, as long as they are small and digestible.  {# Display conversation history if available #} {% if history %} **Conversation History:** {% for message in history %} You: {{- message.content.agent }} Me: {{- message.content.user }} {% endif %} {% endfor %} --- {% endif %}  Bug ID: {{ bug_id }} Timestamp: {{ timestamp }}  --- **User's Description of the Problem:** {{ query }} ---  {% if error_messages %} **Observed Error Messages:** {% for error in error_messages %} - Source: {{ error.source }}   Message: {{ error.text }} {% endfor %} --- {% endif %}  {% if selected %} **User-Selected Context:** The user has highlighted the following code or text: --- {{ selected }} --- {% endif %}  {% if files %} **Relevant Files:** The following files have been provided for context: {% for file in files %} - Name: {{ file.name }}   Contents: {{ file.file_contents }} {% endfor %} --- {% endif %}  Based on the information provided, please return: 1.  A list of hypotheses about the root cause of the bug. 2.  A list of attempts or experiments to test these hypotheses. 3.  (Optional) A list of proposed code edits to fix the bug.",
      'agent_id': 'solver',
      'rag': null,
      'cag': null,
      'value_text': null,
      'html_content': null,
      'parent_agent_id': null,
    },
    {
      'id': '12',
      'input_schema': {
        'schema': 'http://json-schema.org/draft-07/schema#',
        'title': 'Spec LLM Input',
        'description': 'Schema for input to the Spec LLM for general chitchat and Q&A.',
        'long_description':
            'The Spec LLM is used for longer term task planning.  It is aimed at creating a long term step by step plan for a larger task.  It outputs an array of task descriptions.',
        'type': 'object',
        'properties': {
          'model': {
            'description': 'Model to use.',
            'type': 'string',
          },
          'agent_id': {
            'description': 'Unique identifier for the specific agent or role generating the response.',
            'type': 'string',
            'enum': [
              'solver',
              'proofreader',
              'chat',
              'vibe',
              'context',
              'spec',
            ],
          },
          'user_id': {
            'description': 'Unique identifier for the user.',
            'type': 'string',
          },
          'query': {
            'description': "The user's freeform text query or message.",
            'type': 'string',
          },
          'session_id': {
            'description': 'Unique identifier for the current conversation session.',
            'type': 'string',
          },
          'timestamp': {
            'description': "Timestamp of the user's query in ISO 8601 format.",
            'type': 'string',
            'format': 'date-time',
          },
          'metadata': {
            'description': 'An open-ended object for any additional metadata.',
            'type': 'object',
          },
          'files': {
            'description': 'An array of files to include in the context.',
            'type': 'array',
            'items': {
              'type': 'object',
              'properties': {
                'name': {
                  'description':
                      "The name of the LLM. This should be a human-readable identifier for the agent responding, for example, 'Vibe Agent'. Its purpose is to clearly attribute the source of the response.",
                  'type': 'string',
                },
                'filepath': {
                  'description': 'The path to the file on the server.',
                  'type': 'string',
                },
                'file_contents': {
                  'description': 'The contents of the file',
                  'type': 'string',
                },
              },
              'required': [
                'name',
                'filepath',
                'file_contents',
              ],
            },
          },
          'selected': {
            'description': 'Any text or code selected by the user for context',
            'type': 'string',
          },
          'history': {
            'description': 'A list of color updates.',
            'type': 'array',
            'items': {
              'type': 'object',
              'properties': {
                'agent': {
                  'description': "The user's message.",
                  'type': 'string',
                },
                'user': {
                  'description': "The agent's message",
                  'type': 'string',
                },
              },
              'required': [
                'agent',
                'user',
              ],
            },
          },
        },
        'required': [
          'query',
          'user_id',
          'session_id',
          'timestamp',
          'metadata',
        ],
      },
      'output_schema': {
        'schema': 'http://json-schema.org/draft-07/schema#',
        'title': 'Spec LLM Output',
        'description': 'Schema for output to the Spec LLM for general chitchat and Q&A.',
        'long_description':
            'The Spec LLM is used for longer term task planning.  It is aimed at creating a long term step by step plan for a larger task.  It outputs an array of task descriptions.',
        'type': 'object',
        'properties': {
          'name': {
            'description':
                'The name of the LLM. This should be a human-readable identifier for the agent responding. Its purpose is to clearly attribute the source of the response.',
            'type': 'string',
          },
          'response': {
            'description':
                "The LLM's text response to the user's query. This is a user-facing, conversational reply that should summarize the action taken and provide a high-level overview of the changes.",
            'type': 'string',
          },
          'tasklist': {
            'description': 'An ordered list of planned tasks.',
            'type': 'array',
            'items': {
              'type': 'object',
              'properties': {
                'title': {
                  'description': 'The title of the task',
                  'type': 'string',
                },
                'description': {
                  'description': 'The description of the attempt.',
                  'type': 'string',
                },
                'is_complete': {
                  'description': 'Has the task been completed',
                  'type': 'boolean',
                },
              },
              'required': [
                'title',
                'description',
                'is_complete',
              ],
            },
          },
        },
        'required': [
          'name',
          'response',
          'tasklist',
        ],
      },
      'jinja_template':
          "{# This Jinja template formats a JSON object matching the spec-IN.json schema #} {# into a prompt for the Spec LLM, which is designed for long-term task planning. #} {# The goal is to provide all necessary context for the LLM to generate a step-by-step plan. #} {# It omits irrelevant metadata like user_id and session_id. #} You are an expert Jinja developer. {{ name }} Agent Role: Task Planner Purpose: Your job is to create a detailed, multi-step task specification. You will take a high-level request and break it down into a clear, logical plan. Your output should outline the sequence of sub-tasks, and the required inputs and expected outputs for each step of the process. The output should be an array of task descriptions.  {# Display conversation history if available #} {% if history %} **Conversation History:** {% for message in history %} You: {{- message.content.agent }} Me: {{- message.content.user }} {% endif %} {% endfor %} --- {% endif %}  User's request: --- {{ query }} ---  {% if selected %} The user has provided the following selected text for additional context: --- {{ selected }} --- {% endif %}  {% if files %} **Relevant Files:** The following files have been provided for context: {% for file in files %} - Name: {{ file.name }}   Contents: {{ file.file_contents }} {% endfor %} --- {% endif %}  {# The timestamp provides context for when the planning request was made. #} Timestamp: {{ timestamp }}",
      'agent_id': 'spec',
      'rag': null,
      'cag': null,
      'value_text': null,
      'html_content': null,
      'parent_agent_id': null,
    },
    {
      'id': '13',
      'input_schema': {
        'schema': 'http://json-schema.org/draft-07/schema#',
        'title': 'Vibe LLM Output',
        'description': 'Schema for output to the Vibe LLM for quick vibe coding',
        'long_description':
            'The Vibe LLM is used for rapid development and vibe coding.  It will take in a user request, and respond with an array of proposed changes and explanations for each.',
        'type': 'object',
        'properties': {
          'name': {
            'description':
                "The name of the LLM. This should be a human-readable identifier for the agent responding, for example, 'Vibe Agent'. Its purpose is to clearly attribute the source of the response.",
            'type': 'string',
          },
          'response': {
            'description':
                "The LLM's text response to the user's query. This is a user-facing, conversational reply that should summarize the action taken and provide a high-level overview of the changes.",
            'type': 'string',
          },
          'edits': {
            'description':
                'A list of objects detailing edits made to files. This array contains machine-readable instructions for applying changes to the codebase, allowing for automated file modifications.',
            'type': 'array',
            'items': {
              'type': 'object',
              'properties': {
                'edit_id': {
                  'type': 'string',
                  'description':
                      'A unique identifier for the edit, used for tracking and logging purposes. This can be a timestamp, a hash, or any other unique string.',
                },
                'file_path': {
                  'type': 'string',
                  'description':
                      'The full, absolute path to the file where the replacement occurred. This must be an exact path to ensure the correct file is targeted for modification.',
                },
                'old_string': {
                  'type': 'string',
                  'description':
                      'The exact, literal string that was replaced. To ensure a successful patch, this must match the target text precisely, including all whitespace, indentation, and newlines.',
                },
                'new_string': {
                  'type': 'string',
                  'description':
                      'The exact, literal string that replaced the old string. This is the new content that will be written into the file.',
                },
                'justification': {
                  'type': 'string',
                  'description':
                      "A developer-facing explanation of the decision. This field should clarify why the change was made, linking it back to the original user request or the agent's reasoning process.",
                },
              },
              'required': [
                'file_path',
                'old_string',
                'new_string',
              ],
            },
          },
        },
        'required': [
          'name',
          'response',
          'edits',
        ],
      },
      'output_schema': {
        'schema': 'http://json-schema.org/draft-04/schema#',
        'type': 'object',
        'required': [
          'name',
          'response',
          'edits',
        ],
        'properties': {
          'name': {
            'type': 'string',
          },
          'response': {
            'type': 'string',
          },
          'metadata': {
            'type': 'object',
          },
          'edits': {
            'type': 'array',
            'items': [
              {
                'type': 'object',
                'required': [
                  'file_path',
                  'old_string',
                  'new_string',
                ],
                'properties': {
                  'file_path': {
                    'type': 'string',
                  },
                  'old_string': {
                    'type': 'string',
                  },
                  'new_string': {
                    'type': 'string',
                  },
                },
              }
            ],
          },
        },
      },
      'jinja_template':
          "{# This Jinja template formats a JSON object matching the vibe-IN.json schema #} {# into a detailed prompt for the Vibe LLM, which is used for rapid coding tasks. #} {# It focuses on the user's query, task context, selected code, and relevant files, #} {# while omitting metadata like user_id and session_id. #} You are an expert Jinja developer. {{ name }} Agent Role: Incremental Developer Purpose: You are responsible for building up the user's application. You must move slowly and deliberately, making only small changes based on the user's requests. You will not make aggressive or major modifications. If you need clarification on a request, you should always ask the user for more information before proceeding.  Only ask for clarification, do not ask for permission. The user will be able to individually reject or accept each of your edits so do not be timid, as long as they are small and digestible.  {# Display conversation history if available #} {% if history %} **Conversation History:** {% for message in history %} You: {{- message.content.agent }} Me: {{- message.content.user }} {% endif %} {% endfor %} --- {% endif %}  {# The main query or instruction from the user. #} {{ query }}  {# The specific task ID provided by the Architect, giving context to the request. #} {% if task_id %} Task ID: {{ task_id }} {% endif %}  {# Any code or text the user has selected in their editor. #} {% if selected %} The user has the following text selected: --- {{ selected }} --- {% endif %}  {# A list of files provided for context. The LLM should use these files as a reference. #} {% if files %} **Relevant Files:** The following files have been provided for context: {% for file in files %} - Name: {{ file.name }}   Contents: {{ file.file_contents }} {% endfor %} --- {% endif %}  {# Timestamp for temporal context. #} Timestamp: {{ timestamp }}",
      'agent_id': 'vibe',
      'rag': null,
      'cag': null,
      'value_text': null,
      'html_content': null,
      'parent_agent_id': null,
    }
  ],
};

void main() async {
  try {
    final errors = <String?>[];

    // Setup MapLoader with base templates for inheritance and inclusion
    final loader = MapLoader(
      {
        'macro_header': '{% macro macro_header(value) %}<h1>{{ value }}</h1>{% endmacro %}',
      },
      globalJinjaData: jinjaData,
    );

    final env = GetJinja.environment(
      MockBuildContext(),
      loader,
      // enableJinjaDebugLogging: true,
      valueListenableJinjaError: (error) {
        print('Jinja Error: $error');
        errors.add(error);
      },
      callbackToParentProject: ({required payload}) async {
        await Future<void>.delayed(const Duration(seconds: 2));
        print('Mock callbackToParentProject called with: $payload');
        return {
          'workflows': [
            'login',
          ],
          'jinja_data': {
            'username': 'avoavo',
            'password': 'avoavo',
          },
          'workflow_continue': null,
          'client_name': 'jinja-hq',
          'agent_name': 'main',
          'workflow_results': {
            'login': {
              'login_user': {
                'token': 'ef369359-94ab-4f2c-9320-e6c126fc1d17',
              },
              'list_user_servers': {
                'detail': 'User Belongs to No Servers',
              },
              'workflow_log_id': '91afa13e-3832-44b4-b05c-472f2852454b',
            },
          },
        };
      },
      // enableJinjaDebugLogging: true,
    );
    // example 2: real world example
    print('\n=== Example 2: Real world example ===');
    var template2 = env.fromString(jinjaScript);
    var result2 = await template2.renderAsync(jinjaData);
    print('Result length: ${result2.length}');
    print('--------------------------------------------------------------------------------------------------------------------------------');
    print(result2);
    print('--------------------------------------------------------------------------------------------------------------------------------');
  } catch (e, stack) {
    print('\n!!! UNHANDLED EXCEPTION !!!');
    print(e);
    print(stack);
  }
}

Future<String> fetchData() async {
  await Future<void>.delayed(const Duration(milliseconds: 500));
  return 'Data fetched successfully';
}
