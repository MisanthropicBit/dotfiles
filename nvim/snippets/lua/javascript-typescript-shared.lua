local ls = require("luasnip")
local c = ls.choice_node
local f = ls.function_node
local s = ls.snippet
local i = ls.insert_node
local t = ls.text_node
local sn = ls.snippet_node
local extras = require("luasnip.extras")
local rep = extras.rep
local fmt = require("luasnip.extras.fmt").fmt

local fmta = ls.extend_decorator.apply(fmt, { delimiters = "<>" })

-- Generate a range of a node type
---@param min integer
---@param max integer
---@param node_type? any
---@return table
local function range(min, max, node_type)
    local result = {}
    local node = node_type or i

    for idx = min, max do
        table.insert(result, node(idx))
    end

    return result
end

local function strip_graphql_type(args)
    if args then
        return args[1][1]:gsub("(%w+)Type", "%1")
    end
end

local function snake_case(args)
    if args then
        local arg = args[1][1]
        local result = {}

        for idx = 1, #args[1][1] do
            local char = arg:sub(idx, idx)
            local lower = char:lower()

            if lower ~= char then
                table.insert(result, (idx == 1 and "" or "-") .. lower)
            else
                table.insert(result, char)
            end
        end

        return table.concat(result)
    end
end

local function get_mocha_choices(idx)
    return c(
        idx, {
            t('to equal'),
            t('to satisfy'),
            t('to be null'),
            t('to be true'),
            t('to be false'),
            t('to throw'),
            t('to be rejected with'),
            t('to have graphql response'),
            t('to have graphql error'),
            t('to match'),
        }
    )
end

local function get_jest_choices(idx)
    return c(
        idx, {
            t('toEqual'),
            t('toBe'),
            t('toMatchObject'),
            t('toMatchSnapshot'),
        }
    )
end

return {
    -- General
    s("cv", fmta("const <> = <>", { i(1), i(2) })),
    s("ds", fmta("const { <> } = <>", { i(2), i(1) })),
    s("cl", fmt([[console.log({})]], i(1))),
    s("cs", fmt([[console.{}({})]], {
        c(
            1,
            {
                t("log"),
                t("warn"),
                t("error"),
                t("critical"),
                t("dir"),
                t("debug"),
                t("trace"),
                t("table"),
                t("time"),
                t("timeEnd"),
                t("timeLog"),
            }
        ),
        i(2)
    })),
    s("lj", fmt([[console.log(JSON.stringify({}))]], i(1))),
    s("rt", t("return ")),
    s("rn", t("return null")),
    s("ru", t("return undefined")),
    s("ud", t("undefined")),
    s("pe", t("process.env")),

    -- Eslint
    s("elnl", fmt([[// eslint-disable-next-line {}]], i(1))),
    s("telnl", fmt([[// eslint-disable-next-line @typescript-eslint/{}]], i(1))),
    s("nea", t("// eslint-disable-next-line @typescript-eslint/no-explicit-any")),

    -- GraphQL
    s("qb", t("GraphQLBoolean")),
    s("qd", t("GraphQLDate")),
    s("qs", t("GraphQLString")),
    s("qf", t("GraphQLFloat")),
    s("qi", t("GraphQLInt")),
    s("qid", t("GraphQLID")),
    s("ql", t("GraphQLList")),
    s("qn", t("GraphQLNonNull")),
    s({ trig = "qfi", dscr = "GraphQLField snippet" }, fmta([[GraphQLField({
	type: <>,
	description: '<>',
	args: <>,
	resolve: <>
})]],
    range(1, 4)
)),
    s(
        { trig = "qot", dscr = "New GraphQLObjectType" },
        fmta([[import { GraphQLObjectType } from "graphql"

import { GraphQLField } from '../extensions/wrappers'

export const <> = new GraphQLObjectType({
	name: '<>',
	fields: () =>> ({
		<>: GraphQLField({
			type: <>,
			description: '<>'
		})
	})
})]],
            { i(1), f(strip_graphql_type, { 1 }), i(2), i(3), i(4) }
        )
    ),
    s(
        { trig = "qiot", dscr = "New GraphQLInputObjectType" },
        fmta([[import { GraphQLInputObjectType } from 'graphql'

export const <>InputType = new GraphQLInputObjectType({
	name: '<>Input',
	fields: () =>> ({
		<>: {
			type: <>
		}
	})
})]],
        { i(1), rep(1), i(2), i(3) }
        )
    ),
    s(
        { trig = "qet", dscr = "GraphQLEnum type" },
        fmta([[import { GraphQLEnumType } from 'graphql'

export const <>Type = new GraphQLEnumType({
  name: '<>',
  values: {
    <>: { value: '<>' },
  }
})]],
            {
                i(1),
                rep(1),
                i(2),
                rep(2),
            }
        )
    ),
    s(
        { trig = "qef", dscr = "GraphQL expected field test" },
        fmt([[expect(fields, 'to have key', '{}')
expect(fields.{}.type.toString(), 'to be', '{}')
expect(fields.{}.name, 'to be', '{}')]], {
                i(1),
                rep(1),
                i(2),
                rep(1),
                rep(1)
            }
        )
    ),

    -- Testing
    s("ss", fmt("sinon.stub({})", i(1))),
    s("sr", t("sinon.restore()")),
    s("ep", fmt([[expect({}, '{}', {})]], { i(1), get_mocha_choices(2), i(3) })),
    s("ept", fmt([[expect({}).{}({})]], { i(1), get_jest_choices(2), i(3) })),
    s("epct", fmt([[expect({}.callCount).toEqual({})]], range(1, 2))),
    s("epat", fmt([[expect({}.args[0]{}).toEqual([{}])]], range(1, 3))),
    s("epcat", fmt([[expect({}.callCount).toEqual({})
expect({}.args[0]{}).toEqual([{}])]], { i(1), i(2), rep(1), i(3), i(4) })),
    s("epc", fmt([[expect({}.callCount, 'to equal', {})]], range(1, 2))),
    s("epa", fmt([[expect({}.args[0]{}, 'to equal', [{}])]], range(1, 3))),
    s("epca", fmt([[expect({}.callCount, 'to equal', {})
expect({}.args[0]{}, 'to equal', [{}])]], { i(1), i(2), rep(1), i(3), i(4) })),
    s("fss", fmta([[this.<3> = sinon.stub(<1>, '<2>')]], { i(1), i(2), rep(2) })),
    s("des", fmta(
        [[describe('<>', () =>> {
  <>
})]],
        range(1, 2)
    )),
    s("tss", fmt([[TypedSinonStub<typeof {}>]], i(1))),
    s("ftss", fmt([[{}: TypedSinonStub<typeof {}>]], { i(1), i(2) })),
    s("tsp", fmt([[TypedSinonSpy<typeof {}>]], i(1))),
    s("ftsp", fmt([[{}: TypedSinonSpy<typeof {}>]], { i(1), i(2) })),
    s("es", fmt([[envStub = new EnvStub(['{}'])]], i(1))),
    s(
        { trig = "qott", dscr = "New GraphQLObjectType test" },
        fmta([[import { GraphQLObjectType } from 'graphql'

import expect from '../../test/unexpected'
import { <>Type } from './<>-type'

describe('types/<>-type', () =>> {
	describe('<>Type', () =>> {
		it('is correct type', () =>> {
			expect(<>Type, 'to be a', GraphQLObjectType)
			expect(<>Type.toString(), 'to be', '<>')
		})

		it('has correct name', () =>> {
			expect(<>Type.name, 'to be', '<>')
		})

		it('has correct fields', () =>> {
			const fields = <>Type.getFields()

			expect(Object.keys(fields), 'to have length', <>)

			expect(fields, 'to have key', '<>')
			expect(fields.<>.type.toString(), 'to be', '<>')
			expect(fields.<>.name, 'to be', '<>')
		})

		it('has custom resolvers', async () =>> {
			<>
		})
	})
})]],
            {
                i(1),
                f(snake_case, { 1 }),
                f(snake_case, { 1 }),
                rep(1),
                rep(1),
                rep(1),
                rep(1),
                rep(1),
                rep(1),
                rep(1),
                i(2),
                i(3),
                rep(3),
                i(4),
                rep(3),
                rep(3),
                i(5),
            }
        )
    ),
    s(
        { trig = "qiott", dscr = "" },
        fmta([[import { GraphQLInputObjectType } from 'graphql'

import expect from '../../test/unexpected'
import { <>InputType } from './<>-input-type'

describe('types/<>-input-type', function () {
	describe('<>Input', () =>> {
		it('is correct type', () =>> {
			expect(<>InputType, 'to be a', GraphQLInputObjectType)
			expect(<>InputType.toString(), 'to be', '<>Input')
		})

		it('has correct name', () =>> {
			expect(<>InputType.name, 'to be', '<>Input')
		})

		it('has correct fields', () =>> {
			const fields = <>InputType.getFields()

			expect(Object.keys(fields), 'to have length', <>)

			expect(fields, 'to have key', '<>')
			expect(fields.<>.type.toString(), 'to be', '<>')
			expect(fields.<>.name, 'to be', '<>')
		})
	})
})]],
            {
                i(1),
                i(2),
                rep(2),
                rep(1),
                rep(1),
                rep(1),
                rep(1),
                rep(1),
                rep(1),
                rep(1),
                i(3),
                i(4),
                rep(4),
                i(5),
                rep(4),
                rep(4)
            }
        )
    ),
    s(
        { trig = "qett", dscr = "GraphQLEnumType test" },
        fmta([[import expect from '../../../test/unexpected'
import { <>Type } from './<>-type'

describe('types/enums/<>-type', function () {
  describe('<>', () =>> {
    it('has correct type, name, and values', () =>> {
      expect(<>Type, 'to have graphql enum spec', {
        name: '<>',
        values: [<>]
      })
    })
  })
})]],
            {
                i(1),
                f(snake_case, { 1 }),
                f(snake_case, { 1 }),
                rep(1),
                rep(1),
                rep(1),
                i(2),
            }
        )
    ),

    -- Miscellaneous
    s("ar", fmta([[async (obj, args, context) =>> {
	<>
}]], i(1))),
    s("req", fmt([[const {} = require('{}')]], { i(2), i(1) })),
    s("im", fmt([[import {} from {}]], {
        i(2),
        c(1, {
            sn(1, {
                t("{"),
                i(1),
                t("}"),
            }),
            sn(1, {
                t("* as "),
                i(1),
                t("}"),
            }),
        }),
    })),
    s("rcc", fmt([[const {} = require('@connectedcars/{}')]], range(1, 2))),
    s("cc", fmt([[import {} from '@connectedcars/{}']], range(1, 2))),
    s("li", fmt([[log.info({})]], i(1))),
    s("lw", fmt([[log.warn({})]], i(1))),
    s("le", fmt([[log.error({})]], i(1))),
    s("lc", fmt([[log.critical({})]], i(1))),
    s("lg", fmt(
        [[log.{}({})]],
        {
            c(1, {
                t('info'),
                t('warn'),
                t('error'),
                t('critical'),
            }),
            i(2),
        }
    )),
    s(
        { trig = "testfile", dscr = "Javascript test file" },
        fmta([[
const expect = require('../../test/unexpected')
const sinon = require('sinon')

describe('<>', () =>> {
	beforeEach(() =>> {
		<>
	})

	afterEach(async () =>> {
		<>
	})

	it('<>', async () =>> {
		<>
	})
})]],
            range(1, 5)
        )
    ),
    s(
        { trig = "itts", dscr = "Typescript database integration test" },
        fmta([[import { database, testUtils } from '@connectedcars/backend'
import { TypedSinonSpy } from '@connectedcars/test'
import sinon from 'sinon'
<>
const { knex, query } = database
const { IntegrationDatabaseWrapper } = testUtils

describe('it - db/<>', () =>> {
	const db = new IntegrationDatabaseWrapper('<>')
	let querySpy: TypedSinonSpy<<typeof query.knexQuery>>

	beforeEach(async () =>> {
		await db.checkoutDatabase('<>', { truncateTables: ['<>'] })

		querySpy = sinon.spy(query, 'knexQuery')
	})

	afterEach(async () =>> {
		sinon.restore()
		await db.cleanup()
	})

	describe('<>', () =>> {
		it('<>', async () =>> {
			<>

			expect(querySpy.callCount, 'to equal', 1)
			expect(querySpy.args[0][1].toString(), 'to equal', '<>')
		})
	})
})]],
            {
                c(1, {
                    t({ "", "import expect from '../../../test/unexpected'", '' }),
                    t(""),
                }),
                unpack(range(2, 9)),
            }
        )
    ),
    s(
        { trig = "testfilets", dscr = "Typescript test file" },
        fmta([[import sinon from 'sinon'

describe('<>', () =>> {
	beforeEach(() =>> {
		<>
	})

	afterEach(() =>> {
		<>
	})

	it('<>', async () =>> {
		<>
	})
})]],
            range(1, 5)
        )
    ),
    s(
        { trig = "qq", dscr = "A typescript GraphQL query" },
        fmta([[import { GraphQLQuery } from '../extensions/wrappers'
import <> from '../types/<>'

export const <> = GraphQLQuery({
  description: '<>',
  type: <>
  args: {
      <>
  },
  resolve: async (obj, args, context) =>> {
      <>
  }
})]],
            {
                i(1),
                f(snake_case, { 1 }),
                i(2),
                i(3),
                rep(1),
                i(4),
                i(5),
            }
        )
    ),
}
